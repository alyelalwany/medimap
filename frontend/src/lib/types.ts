export type Role = "consumer" | "pharmacy";

export type User = {
  id: number;
  email: string;
  role: Role;
  created_at: string;
  updated_at: string;
};

export type Medicine = {
  id: number;
  name: string;
  active_ingredient: string;
  strength: string;
  form: string;
  created_at: string;
  updated_at: string;
};

export type Pharmacy = {
  id: number;
  user_id: number;
  name: string;
  address: string;
  lat: number;
  lng: number;
  phone?: string | null;
  email?: string | null;
  website?: string | null;
  opening_hours: Record<string, [string, string][]>;
  created_at: string;
  updated_at: string;
};

export type PharmacySearchResult = Pharmacy & {
  distance_meters: number;
  quantity: number;
};

export type StockItem = {
  pharmacy_id: number;
  medicine_id: number;
  medicine?: Medicine;
  quantity: number;
  updated_at: string;
};

export type AuthResponse = {
  user: User;
  token: string;
};
