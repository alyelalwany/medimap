import type {
  AuthResponse,
  Medicine,
  Pharmacy,
  PharmacySearchResult,
  Role,
  StockItem,
  User,
} from "./types";

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8081";

async function req<T>(path: string, init: RequestInit = {}): Promise<T> {
  const res = await fetch(`${API_URL}${path}`, {
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...(init.headers ?? {}),
    },
    ...init,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`${res.status} ${res.statusText}: ${text}`);
  }
  if (res.status === 204) return undefined as T;
  return res.json();
}

export const api = {
  register(email: string, password: string, role: Role) {
    return req<AuthResponse>("/api/auth/register", {
      method: "POST",
      body: JSON.stringify({ email, password, role }),
    });
  },
  login(email: string, password: string) {
    return req<AuthResponse>("/api/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    });
  },
  logout() {
    return req<void>("/api/auth/logout", { method: "POST" });
  },
  me() {
    return req<User>("/api/me");
  },

  searchMedicines(q: string, limit = 10) {
    const p = new URLSearchParams({ q, limit: String(limit) });
    return req<Medicine[]>(`/api/medicines/search?${p}`);
  },

  searchPharmacies(medicineId: number, lat: number, lng: number, radiusKm = 5) {
    const p = new URLSearchParams({
      medicine_id: String(medicineId),
      lat: String(lat),
      lng: String(lng),
      radius_km: String(radiusKm),
    });
    return req<PharmacySearchResult[]>(`/api/pharmacies/search?${p}`);
  },

  // Pharmacy dashboard
  getMyPharmacy() {
    return req<Pharmacy>("/api/pharmacies/me");
  },
  upsertMyPharmacy(input: Omit<Pharmacy, "id" | "user_id" | "created_at" | "updated_at">) {
    return req<Pharmacy>("/api/pharmacies/me", {
      method: "PUT",
      body: JSON.stringify(input),
    });
  },
  listMyStock() {
    return req<StockItem[]>("/api/pharmacies/me/stock");
  },
  upsertStock(medicineId: number, quantity: number) {
    return req<StockItem>("/api/pharmacies/me/stock", {
      method: "PUT",
      body: JSON.stringify({ medicine_id: medicineId, quantity }),
    });
  },
  deleteStock(medicineId: number) {
    return req<void>(`/api/pharmacies/me/stock/${medicineId}`, { method: "DELETE" });
  },

  // Consumer saved medicines
  listSaved() {
    return req<Medicine[]>("/api/me/saved-medicines");
  },
  saveMedicine(medicineId: number) {
    return req<void>("/api/me/saved-medicines", {
      method: "POST",
      body: JSON.stringify({ medicine_id: medicineId }),
    });
  },
  unsaveMedicine(medicineId: number) {
    return req<void>(`/api/me/saved-medicines/${medicineId}`, { method: "DELETE" });
  },
};
