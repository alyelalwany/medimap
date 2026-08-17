"use client";

import { useEffect, useRef } from "react";
import { Map, MapLibreMap, Marker, NavigationControl, Popup } from "maplibre-gl";
import type { StyleSpecification } from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";
import type { PharmacySearchResult } from "@/lib/types";

type Props = {
  center: { lat: number; lng: number };
  pharmacies: PharmacySearchResult[];
  onCenterChange?: (c: { lat: number; lng: number }) => void;
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

export function PharmacyMap({ center, pharmacies, onCenterChange }: Props) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<Map | null>(null);
  const markersRef = useRef<Marker[]>([]);

  useEffect(() => {
    if (!containerRef.current || mapRef.current) return;
    const m = new MapLibreMap({
      container: containerRef.current,
      style: STYLE,
      center: [center.lng, center.lat],
      zoom: 13,
    });
    m.addControl(new NavigationControl({ visualizePitch: false }), "top-right");
    m.on("moveend", () => {
      if (!onCenterChange) return;
      const c = m.getCenter();
      onCenterChange({ lat: c.lat, lng: c.lng });
    });
    mapRef.current = m;
    return () => {
      m.remove();
      mapRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Recentre when center prop changes (e.g. after geolocation).
  useEffect(() => {
    const m = mapRef.current;
    if (!m) return;
    m.easeTo({ center: [center.lng, center.lat] });
  }, [center.lat, center.lng]);

  // Rebuild markers on pharmacies change.
  useEffect(() => {
    const m = mapRef.current;
    if (!m) return;
    markersRef.current.forEach((mk) => mk.remove());
    markersRef.current = pharmacies.map((p) => {
      const popup = new Popup({ offset: 24 }).setHTML(`
        <div style="font-family: system-ui; min-width: 220px;">
          <div style="font-weight: 600; font-size: 15px;">${escapeHTML(p.name)}</div>
          <div style="color: #555; margin-top: 2px;">${escapeHTML(p.address)}</div>
          <div style="margin-top: 6px; font-weight: 600;">${p.quantity} in stock</div>
          <div style="color: #666; font-size: 12px;">${(p.distance_meters / 1000).toFixed(2)} km away</div>
          ${p.phone ? `<div style="margin-top: 6px;">📞 ${escapeHTML(p.phone)}</div>` : ""}
          ${p.website ? `<div>🌐 <a href="${escapeHTML(p.website)}" target="_blank" rel="noreferrer">${escapeHTML(p.website)}</a></div>` : ""}
        </div>
      `);
      return new Marker({ color: "#059669" })
        .setLngLat([p.lng, p.lat])
        .setPopup(popup)
        .addTo(m);
    });
  }, [pharmacies]);

  return <div ref={containerRef} className="h-full w-full" />;
}

function escapeHTML(s: string) {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}
