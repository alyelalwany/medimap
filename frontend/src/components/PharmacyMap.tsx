"use client";

import { useEffect, useRef, useState } from "react";
import { Map as MLMap, Marker, NavigationControl, Popup } from "maplibre-gl";
import type { StyleSpecification } from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";
import type { PharmacySearchResult } from "@/lib/types";

type Props = {
  center: { lat: number; lng: number };
  pharmacies: PharmacySearchResult[];
  focusRequest?: { id: number; nonce: number } | null;
};

// OpenStreetMap raster tiles (no API key required). Fine for dev / MVP.
const STYLE = {
  version: 8,
  sources: {
    osm: {
      type: "raster",
      tiles: ["https://tile.openstreetmap.org/{z}/{x}/{y}.png"],
      tileSize: 256,
      attribution: "© OpenStreetMap contributors",
    },
  },
  layers: [{ id: "osm", type: "raster", source: "osm" }],
} as unknown as StyleSpecification;

function hasWebGL(): boolean {
  if (typeof window === "undefined") return false;
  try {
    const c = document.createElement("canvas");
    return !!(c.getContext("webgl2") || c.getContext("webgl") || c.getContext("experimental-webgl"));
  } catch {
    return false;
  }
}

export function PharmacyMap({ center, pharmacies, focusRequest }: Props) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<MLMap | null>(null);
  const markersRef = useRef<Map<number, Marker>>(new Map());
  const [webglOk, setWebglOk] = useState<boolean | null>(null);

  useEffect(() => {
    setWebglOk(hasWebGL());
  }, []);

  useEffect(() => {
    if (!webglOk || !containerRef.current || mapRef.current) return;
    let m: MLMap;
    try {
      m = new MLMap({
        container: containerRef.current,
        style: STYLE,
        center: [center.lng, center.lat],
        zoom: 13,
      });
    } catch (err) {
      console.error("MapLibre init failed:", err);
      setWebglOk(false);
      return;
    }
    m.on("error", (e) => {
      // WebGL context lost / creation failed — fall back to list view.
      const msg = (e as { error?: { message?: string } }).error?.message ?? "";
      if (msg.toLowerCase().includes("webgl")) setWebglOk(false);
    });
    m.addControl(new NavigationControl({ visualizePitch: false }), "top-right");
    mapRef.current = m;
    return () => {
      m.remove();
      mapRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [webglOk]);

  // Recentre when center prop changes (e.g. after geolocation).
  useEffect(() => {
    const m = mapRef.current;
    if (!m) return;
    m.easeTo({ center: [center.lng, center.lat] });
  }, [center.lat, center.lng]);

  // Reconcile markers when pharmacies change. Only add/remove diffs so the
  // markers for pharmacies that stayed in the results don't flicker.
  useEffect(() => {
    const m = mapRef.current;
    if (!m) return;
    const nextIds = new Set(pharmacies.map((p) => p.id));
    for (const [id, mk] of markersRef.current) {
      if (!nextIds.has(id)) {
        mk.remove();
        markersRef.current.delete(id);
      }
    }
    pharmacies.forEach((p) => {
      if (markersRef.current.has(p.id)) return;
      const popup = new Popup({ offset: 24 }).setHTML(`
        <div style="font-family: system-ui; min-width: 220px; color: #000;">
          <div style="font-weight: 600; font-size: 15px;">${escapeHTML(p.name)}</div>
          <div style="margin-top: 2px;">${escapeHTML(p.address)}</div>
          <div style="margin-top: 6px; font-weight: 600;">${p.quantity} in stock</div>
          <div style="font-size: 12px;">${(p.distance_meters / 1000).toFixed(2)} km away</div>
          ${p.phone ? `<div style="margin-top: 6px;">📞 ${escapeHTML(p.phone)}</div>` : ""}
          ${p.website ? `<div>🌐 <a href="${escapeHTML(p.website)}" target="_blank" rel="noreferrer" style="color: #000; text-decoration: underline;">${escapeHTML(p.website)}</a></div>` : ""}
        </div>
      `);
      const marker = new Marker({ color: "#059669" })
        .setLngLat([p.lng, p.lat])
        .setPopup(popup)
        .addTo(m);
      markersRef.current.set(p.id, marker);
    });
  }, [pharmacies]);

  // Fly to and open popup when a sidebar item is clicked. The nonce lets
  // repeated clicks on the same pharmacy re-trigger the fly-to.
  useEffect(() => {
    if (!focusRequest) return;
    const m = mapRef.current;
    if (!m) return;
    const p = pharmacies.find((x) => x.id === focusRequest.id);
    const marker = markersRef.current.get(focusRequest.id);
    if (!p || !marker) return;
    m.flyTo({ center: [p.lng, p.lat], zoom: Math.max(m.getZoom(), 15), speed: 1.4 });
    const popup = marker.getPopup();
    if (popup && !popup.isOpen()) marker.togglePopup();
  }, [focusRequest, pharmacies]);

  if (webglOk === false) {
    return <FallbackList pharmacies={pharmacies} />;
  }
  return <div ref={containerRef} className="h-full w-full" />;
}

function FallbackList({ pharmacies }: { pharmacies: PharmacySearchResult[] }) {
  return (
    <div className="flex h-full w-full flex-col overflow-auto bg-neutral-50 p-6">
      <div className="mb-4 rounded-md border border-amber-200 bg-amber-50 p-3 text-sm text-amber-900">
        Map view unavailable — your browser doesn&apos;t have WebGL enabled. Showing results as a
        list instead. To restore the map, enable hardware acceleration in your browser settings.
      </div>
      {pharmacies.length === 0 ? (
        <div className="rounded-lg border border-dashed border-neutral-300 p-6 text-center text-sm text-neutral-500">
          Search a medicine to see nearby pharmacies here.
        </div>
      ) : (
        <ul className="space-y-3">
          {pharmacies.map((p) => (
            <li key={p.id} className="rounded-lg border border-neutral-200 bg-white p-4 text-sm">
              <div className="flex items-baseline justify-between">
                <div className="font-semibold text-neutral-900">{p.name}</div>
                <div className="text-xs text-neutral-500">
                  {(p.distance_meters / 1000).toFixed(2)} km
                </div>
              </div>
              <div className="text-neutral-600">{p.address}</div>
              <div className="mt-2 flex flex-wrap items-center gap-3 text-neutral-700">
                <span className="rounded-md bg-emerald-100 px-2 py-0.5 text-xs font-medium text-emerald-800">
                  {p.quantity} in stock
                </span>
                {p.phone && <span>📞 {p.phone}</span>}
                {p.website && (
                  <a
                    href={p.website}
                    target="_blank"
                    rel="noreferrer"
                    className="text-emerald-700 hover:underline"
                  >
                    🌐 website
                  </a>
                )}
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

function escapeHTML(s: string) {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}
