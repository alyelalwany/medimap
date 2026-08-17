-- Generic trigger to keep updated_at fresh on UPDATE.
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to users (added in 0001 without one).
CREATE TRIGGER users_set_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Pharmacies: 1:1 with the owning user (role=pharmacy).
-- Location is GEOGRAPHY so ST_DWithin/ST_Distance return meters directly.
CREATE TABLE pharmacies (
    id             BIGSERIAL PRIMARY KEY,
    user_id        BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    name           TEXT NOT NULL,
    address        TEXT NOT NULL,
    location       GEOGRAPHY(POINT, 4326) NOT NULL,
    phone          TEXT,
    email          TEXT,
    website        TEXT,
    -- Weekly opening hours as JSON, shape TBD by client but keep it flexible.
    -- Example: {"mon": [["08:30","18:30"]], "tue": [...], ..., "sun": []}
    opening_hours  JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX pharmacies_location_gix ON pharmacies USING GIST (location);
CREATE INDEX pharmacies_name_trgm_idx ON pharmacies USING GIN (name gin_trgm_ops);

CREATE TRIGGER pharmacies_set_updated_at
    BEFORE UPDATE ON pharmacies
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Canonical medicine catalog. Pharmacies reference these rows rather than free-typing.
CREATE TABLE medicines (
    id                BIGSERIAL PRIMARY KEY,
    name              TEXT NOT NULL,             -- display / brand name (e.g. "Aspirin")
    active_ingredient TEXT NOT NULL,             -- INN (e.g. "acetylsalicylic acid")
    strength          TEXT NOT NULL,             -- e.g. "500 mg"
    form              TEXT NOT NULL,             -- tablet, syrup, cream, injection, ...
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (active_ingredient, strength, form)
);

-- pg_trgm powers fuzzy search on medicine name / active ingredient.
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX medicines_name_trgm_idx ON medicines USING GIN (name gin_trgm_ops);
CREATE INDEX medicines_ingredient_trgm_idx ON medicines USING GIN (active_ingredient gin_trgm_ops);

CREATE TRIGGER medicines_set_updated_at
    BEFORE UPDATE ON medicines
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Per-pharmacy inventory. quantity=0 = tracked but out of stock. Remove row = not carried.
CREATE TABLE pharmacy_stock (
    pharmacy_id  BIGINT NOT NULL REFERENCES pharmacies(id) ON DELETE CASCADE,
    medicine_id  BIGINT NOT NULL REFERENCES medicines(id)  ON DELETE RESTRICT,
    quantity     INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (pharmacy_id, medicine_id)
);

CREATE INDEX pharmacy_stock_medicine_idx ON pharmacy_stock (medicine_id) WHERE quantity > 0;

CREATE TRIGGER pharmacy_stock_set_updated_at
    BEFORE UPDATE ON pharmacy_stock
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Consumer's saved medicines (favorites).
CREATE TABLE saved_medicines (
    user_id      BIGINT NOT NULL REFERENCES users(id)     ON DELETE CASCADE,
    medicine_id  BIGINT NOT NULL REFERENCES medicines(id) ON DELETE CASCADE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, medicine_id)
);
