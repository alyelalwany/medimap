# Deployment: medimap → Gardener (elalwany shoot)

Deploys medimap as a **read-only public demo** at `https://medimap.elalwany.de`.

## Target

- **Cluster**: Gardener shoot `elalwany` (project `i550774`, canary), AWS eu-west-1, 1 worker node.
- **DNS**: `elalwany.de` at Hostinger. CNAME added manually after first apply.
- **TLS**: Let's Encrypt via [jetstack cert-manager](https://cert-manager.io/), `http01` challenge solved by the nginx ingress. Gardener's `cert.gardener.cloud` extension needed `dns01` which Hostinger doesn't support as a Gardener DNS provider, so we run our own cert-manager instead.
- **Registry**: `docker.io/alyelalwany/medimap-{backend,frontend}` (public).

## One-time prerequisites

Switch kubectl to the shoot:

```bash
ksw elalwany
kubectl config current-context  # should show the elalwany shoot
```

### Install ingress-nginx (once per cluster)

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer
```

### Install cert-manager (once per cluster)

Gardener flags cert-manager's admission webhook as unreachable from the seed's kube-apiserver
unless the webhook uses the node's host network. Install with `webhook.hostNetwork=true`:

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update jetstack
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set crds.enabled=true \
  --set webhook.hostNetwork=true \
  --set webhook.securePort=10260
```

If Gardener auto-remediates the webhook first (edits `timeoutSeconds`), Helm upgrades will hit
a field-manager conflict. Use `--force-conflicts` on subsequent `helm upgrade` calls.

Watch for the ELB hostname:

```bash
kubectl -n ingress-nginx get svc ingress-nginx-controller -w
# EXTERNAL-IP column: something like abc123.elb.eu-west-1.amazonaws.com
```

Copy that hostname — you'll paste it into Hostinger's DNS in a moment.

## Build & push images

Buildx targets `linux/amd64` because the shoot is AWS x86.

```bash
# backend — built from the repo root so db/ is in the build context
docker buildx build --platform linux/amd64 \
  -f backend/Dockerfile -t docker.io/alyelalwany/medimap-backend:v1 --push .

# frontend
docker buildx build --platform linux/amd64 \
  -t docker.io/alyelalwany/medimap-frontend:v1 --push frontend/
```

## Configure secrets

```bash
cp deploy/k8s/secrets.example.yaml deploy/k8s/secrets.yaml
# open deploy/k8s/secrets.yaml and replace the two CHANGE_ME values
# tip: openssl rand -base64 24  → strong Postgres password
#      openssl rand -base64 48  → JWT_SECRET (unused in read-only mode, still required to boot)
```

`deploy/k8s/secrets.yaml` is gitignored.

## Deploy

```bash
kubectl apply -k deploy/k8s/
```

Watch things come up:

```bash
kubectl -n medimap get pods -w
```

The order that should happen:

1. `postgres-0` — `Running` (about 30s).
2. `backend-*` — pending until Postgres is ready; then it runs migrations + seeds on startup and becomes `Ready`.
3. `frontend-*` — `Ready` independently.

If backend crashloops, it's almost always Postgres not accepting connections yet or a bad `DATABASE_URL` — check `kubectl -n medimap logs deploy/backend`.

## DNS

Grab the ELB hostname if you didn't already:

```bash
kubectl -n ingress-nginx get svc ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

At Hostinger → DNS zone editor for `elalwany.de` → add:

- **Type**: CNAME
- **Name**: `medimap`
- **Target**: the ELB hostname (with a trailing dot if the editor requires it)
- **TTL**: 300

Verify propagation:

```bash
dig +short medimap.elalwany.de
# should return the ELB IPs (dig follows the CNAME to the ELB's A records)
```

## TLS

cert-manager sees the `Ingress`'s `cert-manager.io/cluster-issuer: letsencrypt-prod` annotation
and the `Certificate` resource, then runs an `http01` challenge through the ingress. Check status:

```bash
kubectl -n medimap get certificate.cert-manager.io medimap-tls
# READY column should be True within a couple of minutes after DNS resolves
```

If it stays `False`, describe it:

```bash
kubectl -n medimap describe certificate.cert-manager.io medimap-tls
kubectl -n medimap get challenges.acme.cert-manager.io
```

Common causes:
- DNS not propagated yet (wait; verify with `dig +short medimap.elalwany.de`).
- Rate-limited by Let's Encrypt (wait an hour, don't retry aggressively).
- ingress-nginx not routing `/.well-known/acme-challenge/*` — check the controller logs.

## Verify

```bash
curl https://medimap.elalwany.de/healthz
# {"ok":true}

curl "https://medimap.elalwany.de/api/medicines/search?q=ibu"
# JSON list

curl -X POST https://medimap.elalwany.de/api/auth/login \
  -H "Content-Type: application/json" -d '{"email":"x","password":"y"}'
# 404 — mutation routes are not registered in read-only mode
```

Then open `https://medimap.elalwany.de` in a browser and confirm the map + search work.

## Updating

Bump the image tag, push, patch the Deployment:

```bash
docker buildx build --platform linux/amd64 \
  -f backend/Dockerfile -t docker.io/alyelalwany/medimap-backend:v2 --push .

kubectl -n medimap set image deploy/backend backend=docker.io/alyelalwany/medimap-backend:v2
kubectl -n medimap rollout status deploy/backend
```

## Uninstall

```bash
kubectl delete -k deploy/k8s/
# Postgres PVC is retained by design — delete it manually if you also want the DB gone:
kubectl -n medimap delete pvc data-postgres-0
```

Then optionally remove the Hostinger CNAME and uninstall ingress-nginx if nothing else uses it.
