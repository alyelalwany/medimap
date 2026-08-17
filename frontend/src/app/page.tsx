"use client";

import { useEffect, useState } from "react";
import { MedicineSearchBar } from "@/components/MedicineSearchBar";
import { PharmacyMap } from "@/components/PharmacyMap";
import { api } from "@/lib/api";
import type { Medicine, PharmacySearchResult } from "@/lib/types";

// Default view: Berlin Mitte. Users can Use my location to override.
const DEFAULT_CENTER = { lat: 52.52, lng: 13.405 };

export default function Home() {
  const [center, setCenter] = useState(DEFAULT_CENTER);
  const [selected, setSelected] = useState<Medicine | null>(null);
  const [results, setResults] = useState<PharmacySearchResult[]>([]);
  const [radiusKm, setRadiusKm] = useState(5);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!selected) {
      setResults([]);
      return;
    }
    setBusy(true);
    setError(null);
    api
      .searchPharmacies(selected.id, center.lat, center.lng, radiusKm)
      .then(setResults)
      .catch((e: Error) => setError(e.message))
      .finally(() => setBusy(false));
  }, [selected, center.lat, center.lng, radiusKm]);

  function useMyLocation() {
    if (!("geolocation" in navigator)) return;
    navigator.geolocation.getCurrentPosition(
      (pos) => setCenter({ lat: pos.coords.latitude, lng: pos.coords.longitude }),
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
            {results.map((p) => (
              <li
                key={p.id}
                className="rounded-lg border border-neutral-200 bg-neutral-50 p-3 text-sm"
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
            ))}
          </ul>
        </div>
      </aside>

      <div className="min-h-[400px] flex-1 md:min-h-0">
        <PharmacyMap center={center} pharmacies={results} onCenterChange={setCenter} />
      </div>
    </div>
  );
}
