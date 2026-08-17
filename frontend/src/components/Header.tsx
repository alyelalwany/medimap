"use client";

import Link from "next/link";
import { useAuth } from "@/lib/auth-context";

export function Header() {
  const { user, loading, logout } = useAuth();

  return (
    <header className="flex items-center justify-between border-b border-neutral-200 bg-white px-6 py-3">
      <Link href="/" className="text-xl font-semibold text-emerald-700">
        medimap
      </Link>
      <nav className="flex items-center gap-4 text-sm">
        {!loading && !user && (
          <>
            <Link href="/login" className="text-neutral-700 hover:text-emerald-700">
              Log in
            </Link>
            <Link
              href="/register"
              className="rounded-lg bg-emerald-600 px-3 py-1.5 text-white hover:bg-emerald-700"
            >
              Sign up
            </Link>
          </>
        )}
        {!loading && user && (
          <>
            <span className="text-neutral-500">
              {user.email} · <span className="font-medium">{user.role}</span>
            </span>
            {user.role === "pharmacy" && (
              <Link href="/dashboard" className="text-neutral-700 hover:text-emerald-700">
                Dashboard
              </Link>
            )}
            {user.role === "consumer" && (
              <Link href="/saved" className="text-neutral-700 hover:text-emerald-700">
                Saved
              </Link>
            )}
            <button
              onClick={() => void logout()}
              className="rounded-lg border border-neutral-300 px-3 py-1.5 text-neutral-700 hover:bg-neutral-100"
            >
              Log out
            </button>
          </>
        )}
      </nav>
    </header>
  );
}
