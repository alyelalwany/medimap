import { READ_ONLY } from "@/lib/mode";

export function DemoBanner() {
  if (!READ_ONLY) return null;
  return (
    <div className="bg-amber-50 border-b border-amber-200 px-6 py-1.5 text-center text-xs text-amber-900">
      Read-only demo · seeded data ·{" "}
      <a
        href="https://github.com/alyelalwany/medimap"
        className="underline hover:text-amber-950"
      >
        source on GitHub
      </a>
    </div>
  );
}
