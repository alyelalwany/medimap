"use client";

import { useRouter } from "next/navigation";
import Link from "next/link";
import { useState } from "react";
import { api } from "@/lib/api";
import { useAuth } from "@/lib/auth-context";
import type { Role } from "@/lib/types";

export default function RegisterPage() {
  const router = useRouter();
  const { refresh } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [role, setRole] = useState<Role>("consumer");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const res = await api.register(email, password, role);
      await refresh();
      router.push(res.user.role === "pharmacy" ? "/dashboard" : "/");
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="mx-auto flex w-full max-w-md flex-1 flex-col justify-center px-6 py-12">
      <h1 className="text-2xl font-bold text-neutral-900">Create an account</h1>
      <form onSubmit={onSubmit} className="mt-6 space-y-4">
        <div className="grid grid-cols-2 gap-3">
          <button
            type="button"
            onClick={() => setRole("consumer")}
            className={`rounded-md border px-3 py-2 text-sm ${
              role === "consumer"
                ? "border-emerald-500 bg-emerald-50 text-emerald-800"
                : "border-neutral-300 bg-white text-neutral-700 hover:bg-neutral-50"
            }`}
          >
            I&apos;m a consumer
          </button>
          <button
            type="button"
            onClick={() => setRole("pharmacy")}
            className={`rounded-md border px-3 py-2 text-sm ${
              role === "pharmacy"
                ? "border-emerald-500 bg-emerald-50 text-emerald-800"
                : "border-neutral-300 bg-white text-neutral-700 hover:bg-neutral-50"
            }`}
          >
            I&apos;m a pharmacy
          </button>
        </div>
        <div>
          <label className="block text-sm text-neutral-700">Email</label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="mt-1 w-full rounded-md border border-neutral-300 bg-white px-3 py-2 text-neutral-900 outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200"
          />
        </div>
        <div>
          <label className="block text-sm text-neutral-700">Password (min 8)</label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            minLength={8}
            required
            className="mt-1 w-full rounded-md border border-neutral-300 bg-white px-3 py-2 text-neutral-900 outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-200"
          />
        </div>
        {error && <div className="text-sm text-red-600">{error}</div>}
        <button
          disabled={busy}
          className="w-full rounded-md bg-emerald-600 py-2 text-white hover:bg-emerald-700 disabled:opacity-60"
        >
          {busy ? "Creating…" : "Sign up"}
        </button>
      </form>
      <p className="mt-4 text-sm text-neutral-600">
        Already have an account?{" "}
        <Link href="/login" className="text-emerald-700 hover:underline">
          Log in
        </Link>
      </p>
    </div>
  );
}
