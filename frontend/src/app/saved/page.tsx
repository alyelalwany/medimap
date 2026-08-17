"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import type { Medicine } from "@/lib/types";

export default function SavedPage() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const [items, setItems] = useState<Medicine[]>([]);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (!loading && (!user || user.role !== "consumer")) {
      router.push("/login");
    }
  }, [user, loading, router]);

  async function load() {
    setBusy(true);
    try {
      setItems(await api.listSaved());
    } finally {
      setBusy(false);
    }
  }

  useEffect(() => {
    if (user?.role === "consumer") void load();
  }, [user]);

  async function remove(id: number) {
    await api.unsaveMedicine(id);
    await load();
  }

  if (loading || !user || user.role !== "consumer") {
    return <div className="p-6 text-neutral-600">Loading…</div>;
  }

  return (
    <div className="mx-auto w-full max-w-3xl p-6">
      <h1 className="text-2xl font-bold text-neutral-900">Saved medicines</h1>
      <p className="mt-1 text-sm text-neutral-600">
        Quickly re-search medicines you need often.
      </p>

      <div className="mt-6">
        {busy && <div className="text-neutral-500">Loading…</div>}
        {!busy && items.length === 0 && (
          <div className="rounded-md border border-dashed border-neutral-300 p-6 text-center text-sm text-neutral-500">
            You haven&apos;t saved any medicines yet. Search a medicine on the home page and
            save it from the results.
          </div>
        )}
        <ul className="space-y-3">
          {items.map((m) => (
            <li
              key={m.id}
              className="flex items-center justify-between rounded-lg border border-neutral-200 bg-white p-4"
            >
              <div>
                <div className="font-semibold text-neutral-900">
                  {m.name} · {m.strength}
                </div>
                <div className="text-sm text-neutral-500">
                  {m.active_ingredient} · {m.form}
                </div>
              </div>
              <button
                onClick={() => void remove(m.id)}
                className="rounded-md border border-neutral-300 px-3 py-1 text-sm text-neutral-700 hover:bg-neutral-100"
              >
                Remove
              </button>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
