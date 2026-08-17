"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import type { Medicine, Pharmacy, StockItem } from "@/lib/types";

export default function DashboardPage() {
  const { user, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && (!user || user.role !== "pharmacy")) {
      router.push("/login");
    }
  }, [user, loading, router]);

  if (loading || !user || user.role !== "pharmacy") {
    return <div className="p-6 text-neutral-600">Loading…</div>;
  }

  return (
    <div className="mx-auto w-full max-w-4xl p-6">
      <h1 className="text-2xl font-bold text-neutral-900">Pharmacy dashboard</h1>
      <p className="mt-1 text-sm text-neutral-600">
        Keep your profile and inventory up to date so consumers can find you.
      </p>
      <div className="mt-8 grid gap-8 md:grid-cols-1">
        <PharmacyProfile />
        <StockManager />
      </div>
    </div>
  );
}

function PharmacyProfile() {
  const [form, setForm] = useState<Partial<Pharmacy>>({
    name: "",
    address: "",
    lat: 52.52,
    lng: 13.405,
    phone: "",
    email: "",
    website: "",
    opening_hours: {},
  });
  const [msg, setMsg] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    api
      .getMyPharmacy()
      .then((p) => setForm(p))
      .catch(() => {
        /* new pharmacy - keep defaults */
      })
      .finally(() => setLoaded(true));
  }, []);

  async function save(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setMsg(null);
    try {
      const p = await api.upsertMyPharmacy({
        name: form.name ?? "",
        address: form.address ?? "",
        lat: Number(form.lat),
        lng: Number(form.lng),
        phone: form.phone ?? null,
        email: form.email ?? null,
        website: form.website ?? null,
        opening_hours: form.opening_hours ?? {},
      });
      setForm(p);
      setMsg("Saved.");
    } catch (err) {
      setMsg((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  if (!loaded) return <div className="text-neutral-500">Loading profile…</div>;

  return (
    <section className="rounded-lg border border-neutral-200 bg-white p-6">
      <h2 className="text-lg font-semibold text-neutral-900">Profile</h2>
      <form onSubmit={save} className="mt-4 grid grid-cols-1 gap-4 md:grid-cols-2">
        <Field label="Name">
          <input
            required
            value={form.name ?? ""}
            onChange={(e) => setForm({ ...form, name: e.target.value })}
            className={inputClass}
          />
        </Field>
        <Field label="Address">
          <input
            required
            value={form.address ?? ""}
            onChange={(e) => setForm({ ...form, address: e.target.value })}
            className={inputClass}
          />
        </Field>
        <Field label="Latitude">
          <input
            type="number"
            step="any"
            required
            value={form.lat ?? ""}
            onChange={(e) => setForm({ ...form, lat: Number(e.target.value) })}
            className={inputClass}
          />
        </Field>
        <Field label="Longitude">
          <input
            type="number"
            step="any"
            required
            value={form.lng ?? ""}
            onChange={(e) => setForm({ ...form, lng: Number(e.target.value) })}
            className={inputClass}
          />
        </Field>
        <Field label="Phone">
          <input
            value={form.phone ?? ""}
            onChange={(e) => setForm({ ...form, phone: e.target.value })}
            className={inputClass}
          />
        </Field>
        <Field label="Email">
          <input
            type="email"
            value={form.email ?? ""}
            onChange={(e) => setForm({ ...form, email: e.target.value })}
            className={inputClass}
          />
        </Field>
        <Field label="Website" className="md:col-span-2">
          <input
            type="url"
            value={form.website ?? ""}
            onChange={(e) => setForm({ ...form, website: e.target.value })}
            className={inputClass}
          />
        </Field>
        <div className="flex items-center gap-4 md:col-span-2">
          <button
            disabled={busy}
            className="rounded-md bg-emerald-600 px-4 py-2 text-white hover:bg-emerald-700 disabled:opacity-60"
          >
            {busy ? "Saving…" : "Save profile"}
          </button>
          {msg && <span className="text-sm text-neutral-600">{msg}</span>}
        </div>
      </form>
    </section>
  );
}

function StockManager() {
  const [items, setItems] = useState<StockItem[]>([]);
  const [pickerQuery, setPickerQuery] = useState("");
  const [pickerResults, setPickerResults] = useState<Medicine[]>([]);
  const [picked, setPicked] = useState<Medicine | null>(null);
  const [qty, setQty] = useState<number>(1);
  const [msg, setMsg] = useState<string | null>(null);

  async function load() {
    try {
      setItems(await api.listMyStock());
    } catch {
      setItems([]);
    }
  }
  useEffect(() => {
    void load();
  }, []);

  useEffect(() => {
    let cancelled = false;
    if (pickerQuery.trim().length < 2) {
      setPickerResults([]);
      return;
    }
    const t = setTimeout(async () => {
      try {
        const r = await api.searchMedicines(pickerQuery.trim());
        if (!cancelled) setPickerResults(r);
      } catch {
        if (!cancelled) setPickerResults([]);
      }
    }, 200);
    return () => {
      cancelled = true;
      clearTimeout(t);
    };
  }, [pickerQuery]);

  async function addOrUpdate() {
    if (!picked) return;
    setMsg(null);
    try {
      await api.upsertStock(picked.id, qty);
      setPicked(null);
      setPickerQuery("");
      setQty(1);
      await load();
    } catch (err) {
      setMsg((err as Error).message);
    }
  }

  async function updateQty(medicineId: number, quantity: number) {
    try {
      await api.upsertStock(medicineId, quantity);
      await load();
    } catch (err) {
      setMsg((err as Error).message);
    }
  }

  async function remove(medicineId: number) {
    try {
      await api.deleteStock(medicineId);
      await load();
    } catch (err) {
      setMsg((err as Error).message);
    }
  }

  return (
    <section className="rounded-lg border border-neutral-200 bg-white p-6">
      <h2 className="text-lg font-semibold text-neutral-900">Inventory</h2>

      <div className="mt-4 rounded-md border border-neutral-200 bg-neutral-50 p-4">
        <div className="text-sm font-medium text-neutral-700">Add or update stock</div>
        <div className="mt-3 flex flex-col gap-2 md:flex-row md:items-center">
          <div className="relative flex-1">
            <input
              placeholder="Search medicine…"
              value={pickerQuery}
              onChange={(e) => {
                setPickerQuery(e.target.value);
                setPicked(null);
              }}
              className={inputClass}
            />
            {pickerResults.length > 0 && !picked && (
              <ul className="absolute z-10 mt-1 max-h-64 w-full overflow-auto rounded-md border border-neutral-200 bg-white shadow">
                {pickerResults.map((m) => (
                  <li
                    key={m.id}
                    className="cursor-pointer border-b border-neutral-100 px-3 py-2 text-sm hover:bg-emerald-50"
                    onMouseDown={() => {
                      setPicked(m);
                      setPickerQuery(`${m.name} ${m.strength}`);
                      setPickerResults([]);
                    }}
                  >
                    <div className="font-medium">
                      {m.name} · {m.strength}
                    </div>
                    <div className="text-neutral-500">
                      {m.active_ingredient} · {m.form}
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </div>
          <input
            type="number"
            min={0}
            value={qty}
            onChange={(e) => setQty(Number(e.target.value))}
            className={`${inputClass} w-full md:w-24`}
          />
          <button
            disabled={!picked}
            onClick={addOrUpdate}
            className="rounded-md bg-emerald-600 px-4 py-2 text-white hover:bg-emerald-700 disabled:opacity-40"
          >
            Save
          </button>
        </div>
        {msg && <div className="mt-2 text-sm text-red-600">{msg}</div>}
      </div>

      <div className="mt-6">
        {items.length === 0 ? (
          <div className="rounded-md border border-dashed border-neutral-300 p-6 text-center text-sm text-neutral-500">
            No stock yet. Add one above.
          </div>
        ) : (
          <table className="w-full text-sm">
            <thead className="text-left text-neutral-500">
              <tr>
                <th className="py-2">Medicine</th>
                <th className="py-2">Qty</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {items.map((it) => (
                <tr key={it.medicine_id} className="border-t border-neutral-100">
                  <td className="py-2">
                    <div className="font-medium text-neutral-900">
                      {it.medicine?.name} · {it.medicine?.strength}
                    </div>
                    <div className="text-neutral-500">
                      {it.medicine?.active_ingredient} · {it.medicine?.form}
                    </div>
                  </td>
                  <td className="py-2">
                    <input
                      type="number"
                      min={0}
                      defaultValue={it.quantity}
                      onBlur={(e) => {
                        const v = Number(e.target.value);
                        if (v !== it.quantity) void updateQty(it.medicine_id, v);
                      }}
                      className={`${inputClass} w-20`}
                    />
                  </td>
                  <td className="py-2 text-right">
                    <button
                      onClick={() => void remove(it.medicine_id)}
                      className="rounded-md border border-neutral-300 px-3 py-1 text-neutral-700 hover:bg-neutral-100"
                    >
                      Remove
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </section>
  );
}

const inputClass =
  "w-full rounded-md border border-neutral-300 bg-white px-3 py-2 text-neutral-900 outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200";

function Field({
  label,
  children,
  className = "",
}: {
  label: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <label className={`block ${className}`}>
      <span className="block text-sm text-neutral-700">{label}</span>
      <span className="mt-1 block">{children}</span>
    </label>
  );
}
