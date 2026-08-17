"use client";

import { useEffect, useRef, useState } from "react";
import { api } from "@/lib/api";
import type { Medicine } from "@/lib/types";

type Props = {
  onSelect: (m: Medicine) => void;
};

export function MedicineSearchBar({ onSelect }: Props) {
  const [q, setQ] = useState("");
  const [results, setResults] = useState<Medicine[]>([]);
  const [open, setOpen] = useState(false);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    if (timer.current) clearTimeout(timer.current);
    if (q.trim().length < 2) {
      setResults([]);
      return;
    }
    timer.current = setTimeout(async () => {
      try {
        const r = await api.searchMedicines(q.trim());
        setResults(r);
        setOpen(true);
      } catch {
        setResults([]);
      }
    }, 200);
    return () => {
      if (timer.current) clearTimeout(timer.current);
    };
  }, [q]);

  return (
    <div className="relative w-full max-w-xl">
      <input
        type="text"
        value={q}
        placeholder="Search a medicine (e.g. Ibuprofen)"
        onChange={(e) => setQ(e.target.value)}
        onFocus={() => results.length > 0 && setOpen(true)}
        onBlur={() => setTimeout(() => setOpen(false), 150)}
        className="w-full rounded-lg border border-neutral-300 bg-white px-4 py-3 text-neutral-900 shadow-sm outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200"
      />
      {open && results.length > 0 && (
        <ul className="absolute z-20 mt-1 max-h-80 w-full overflow-auto rounded-lg border border-neutral-200 bg-white shadow-lg">
          {results.map((m) => (
            <li
              key={m.id}
              className="cursor-pointer border-b border-neutral-100 px-4 py-2 hover:bg-emerald-50"
              onMouseDown={() => {
                onSelect(m);
                setQ(`${m.name} ${m.strength}`);
                setOpen(false);
              }}
            >
              <div className="font-medium text-neutral-900">
                {m.name} <span className="text-neutral-500">· {m.strength}</span>
              </div>
              <div className="text-sm text-neutral-500">
                {m.active_ingredient} · {m.form}
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
