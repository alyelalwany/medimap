"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { MedicineSearchBar } from "@/components/MedicineSearchBar";
import { PharmacyMap } from "@/components/PharmacyMap";
import { api } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import type { Medicine, PharmacySearchResult } from "@/lib/types";

// Default view: Munich centre. Users can Use my location to override.
const DEFAULT_CENTER = { lat: 48.1371, lng: 11.5754 };

export default function Home() {
  const { user } = useAuth();
  // `searchOrigin` is the point used for the pharmacy query. It only changes
  // when the user asks it to (default, "Use my location", or a future
  // "search here" button). The map's own pan/zoom does NOT change it —
  // otherwise every map move (including our own flyTo) would refetch and
  // rebuild markers, causing a visible flicker.
  const [searchOrigin, setSearchOrigin] = useState(DEFAULT_CENTER);
  const [selected, setSelected] = useState<Medicine | null>(null);
  const [results, setResults] = useState<PharmacySearchResult[]>([]);
  const [radiusKm, setRadiusKm] = useState(5);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [savedIds, setSavedIds] = useState<Set<number>>(new Set());
  const [saveBusy, setSaveBusy] = useState(false);
  const [focus, setFocus] = useState<{ id: number; nonce: number } | null>(null);

  useEffect(() => {
    if (user?.role !== "consumer") {
      setSavedIds(new Set());
      return;
    }
    api
      .listSaved()
      .then((items) => setSavedIds(new Set(items.map((m) => m.id))))
      .catch(() => setSavedIds(new Set()));
  }, [user]);

  useEffect(() => {
    if (!selected) {
      setResults([]);
      return;
    }
    setBusy(true);
    setError(null);
    api
      .searchPharmacies(selected.id, searchOrigin.lat, searchOrigin.lng, radiusKm)
      .then(setResults)
      .catch((e: Error) => setError(e.message))
      .finally(() => setBusy(false));
  }, [selected, searchOrigin.lat, searchOrigin.lng, radiusKm]);

  function useMyLocation() {
    if (!("geolocation" in navigator)) return;
    navigator.geolocation.getCurrentPosition(
      (pos) => setSearchOrigin({ lat: pos.coords.latitude, lng: pos.coords.longitude }),
      () => {
        /* keep default */
      },
      { enableHighAccuracy: true, timeout: 5000 },
    );
  }

  return (
    <div className="flex flex-1 flex-col md:flex-row">
      <aside className="flex w-full flex-col gap-4 border-r border-neutral-200 bg-white p-6 md:w-[420px]">
        <div>
          <h1 className="text-2xl font-bold text-neutral-900">Find a medicine near you</h1>
          <p className="mt-1 text-sm text-neutral-600">
            Search a medicine — nearby pharmacies with it in stock appear on the map.
          </p>
        </div>

        <MedicineSearchBar onSelect={setSelected} />

        {selected && (
          <div className="flex items-center justify-between rounded-md border border-neutral-200 bg-neutral-50 px-3 py-2">
            <div className="min-w-0">
              <div className="truncate text-sm font-semibold text-neutral-900">
                {selected.name} · {selected.strength}
              </div>
              <div className="truncate text-xs text-neutral-500">
                {selected.active_ingredient} · {selected.form}
              </div>
            </div>
            <SaveButton
              medicine={selected}
              user={user}
              saved={savedIds.has(selected.id)}
              busy={saveBusy}
              onToggle={async () => {
                if (!user || user.role !== "consumer") return;
                setSaveBusy(true);
                try {
                  if (savedIds.has(selected.id)) {
                    await api.unsaveMedicine(selected.id);
                    setSavedIds((prev) => {
                      const next = new Set(prev);
                      next.delete(selected.id);
                      return next;
                    });
                  } else {
                    await api.saveMedicine(selected.id);
                    setSavedIds((prev) => new Set(prev).add(selected.id));
                  }
                } finally {
                  setSaveBusy(false);
                }
              }}
            />
          </div>
        )}

        <div className="flex items-center gap-3">
          <label className="text-sm text-neutral-600">Radius</label>
          <select
            value={radiusKm}
            onChange={(e) => setRadiusKm(Number(e.target.value))}
            className="rounded-md border border-neutral-300 bg-white px-2 py-1 text-sm"
          >
            {[1, 2, 5, 10, 20, 50].map((r) => (
              <option key={r} value={r}>
                {r} km
              </option>
            ))}
          </select>
          <button
            onClick={useMyLocation}
            className="ml-auto rounded-md border border-neutral-300 px-3 py-1 text-sm hover:bg-neutral-100"
          >
            Use my location
          </button>
        </div>

        <div className="flex-1 overflow-auto">
          {!selected && (
            <div className="rounded-lg border border-dashed border-neutral-300 p-6 text-center text-sm text-neutral-500">
              Start by searching a medicine above.
            </div>
          )}
          {selected && busy && <div className="text-sm text-neutral-500">Searching…</div>}
          {error && <div className="text-sm text-red-600">{error}</div>}
          {selected && !busy && results.length === 0 && (
            <div className="rounded-lg border border-dashed border-neutral-300 p-6 text-center text-sm text-neutral-500">
              No pharmacies within {radiusKm} km have this in stock.
            </div>
          )}
          <ul className="space-y-3">
            {results.map((p) => {
              const isFocused = focus?.id === p.id;
              return (
                <li
                  key={p.id}
                  onClick={() =>
                    setFocus((f) => ({ id: p.id, nonce: (f?.nonce ?? 0) + 1 }))
                  }
                  className={`cursor-pointer rounded-lg border p-3 text-sm transition-colors ${
                    isFocused
                      ? "border-emerald-400 bg-emerald-50 ring-2 ring-emerald-200"
                      : "border-neutral-200 bg-neutral-50 hover:border-emerald-300 hover:bg-white"
                  }`}
                >
                  <div className="flex items-baseline justify-between">
                    <div className="font-semibold text-neutral-900">{p.name}</div>
                    <div className="text-xs text-neutral-500">
                      {(p.distance_meters / 1000).toFixed(2)} km
                    </div>
                  </div>
                  <div className="text-neutral-600">{p.address}</div>
                  <div className="mt-2 flex items-center gap-3 text-neutral-700">
                    <span className="rounded-md bg-emerald-100 px-2 py-0.5 font-medium text-emerald-800">
                      {p.quantity} in stock
                    </span>
                    {p.phone && <span>📞 {p.phone}</span>}
                  </div>
                </li>
              );
            })}
          </ul>
        </div>
      </aside>

      <div className="min-h-[400px] flex-1 md:min-h-0">
        <PharmacyMap
          center={searchOrigin}
          pharmacies={results}
          focusRequest={focus}
        />
      </div>
    </div>
  );
}

function SaveButton({
  medicine,
  user,
  saved,
  busy,
  onToggle,
}: {
  medicine: Medicine;
  user: { role: string } | null;
  saved: boolean;
  busy: boolean;
  onToggle: () => void;
}) {
  if (!user) {
    return (
      <Link
        href="/login"
        className="ml-3 shrink-0 rounded-md border border-neutral-300 px-3 py-1 text-xs text-neutral-700 hover:bg-neutral-100"
      >
        Log in to save
      </Link>
    );
  }
  if (user.role !== "consumer") {
    return null;
  }
  return (
    <button
      onClick={onToggle}
      disabled={busy}
      title={saved ? "Remove from saved medicines" : "Save this medicine to your profile"}
      className={`ml-3 shrink-0 rounded-md border px-3 py-1 text-xs font-medium disabled:opacity-60 ${
        saved
          ? "border-emerald-300 bg-emerald-50 text-emerald-800 hover:bg-emerald-100"
          : "border-neutral-300 bg-white text-neutral-700 hover:bg-neutral-100"
      }`}
      aria-pressed={saved}
    >
      {saved ? "✓ Saved" : "Save"}
      <span className="sr-only"> {medicine.name}</span>
    </button>
  );
}
