-- Seed demo pharmacies + stock in Munich. Idempotent: safe to re-run.
-- All demo pharmacy users share the password "demo1234" (same as Berlin seed).
-- Coordinates cluster around Munich city centre and popular districts.

-- Insert users (pharmacy owners). password_hash = bcrypt("demo1234").
INSERT INTO users (email, password_hash, role) VALUES
    ('marienplatz@demo.medimap',  '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('schwabing@demo.medimap',    '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('haidhausen@demo.medimap',   '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('sendling@demo.medimap',     '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('maxvorstadt@demo.medimap',  '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('bogenhausen@demo.medimap',  '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy')
ON CONFLICT (email) DO NOTHING;

-- Insert pharmacies referencing the users above. Match by owner email so re-runs are safe.
INSERT INTO pharmacies (user_id, name, address, location, phone, email, website, opening_hours)
SELECT u.id, v.name, v.address,
       ST_SetSRID(ST_MakePoint(v.lng, v.lat), 4326)::geography,
       v.phone, v.email, v.website, v.opening_hours::jsonb
FROM (VALUES
    ('marienplatz@demo.medimap',  'Alte Hof-Apotheke',            'Sendlinger Str. 8, 80331 München',
        11.5720, 48.1360, '+49 89 22334401', 'kontakt@altehof-demo.de', 'https://altehof-demo.medimap.local',
        '{"mon":[["08:00","20:00"]],"tue":[["08:00","20:00"]],"wed":[["08:00","20:00"]],"thu":[["08:00","20:00"]],"fri":[["08:00","20:00"]],"sat":[["09:00","18:00"]],"sun":[]}'),
    ('schwabing@demo.medimap',    'Schwabinger Apotheke',         'Leopoldstr. 62, 80802 München',
        11.5860, 48.1620, '+49 89 22334402', 'kontakt@schwabinger-demo.de', 'https://schwabinger-demo.medimap.local',
        '{"mon":[["08:30","19:00"]],"tue":[["08:30","19:00"]],"wed":[["08:30","19:00"]],"thu":[["08:30","19:00"]],"fri":[["08:30","19:00"]],"sat":[["09:00","16:00"]],"sun":[]}'),
    ('haidhausen@demo.medimap',   'Wiener Platz-Apotheke',        'Wiener Platz 5, 81667 München',
        11.5940, 48.1330, '+49 89 22334403', 'kontakt@wiener-demo.de', 'https://wiener-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('sendling@demo.medimap',     'Isar-Apotheke',                'Lindwurmstr. 122, 80337 München',
        11.5510, 48.1240, '+49 89 22334404', 'kontakt@isar-demo.de', 'https://isar-demo.medimap.local',
        '{"mon":[["08:00","19:00"]],"tue":[["08:00","19:00"]],"wed":[["08:00","19:00"]],"thu":[["08:00","19:00"]],"fri":[["08:00","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('maxvorstadt@demo.medimap',  'Universitäts-Apotheke',        'Türkenstr. 65, 80799 München',
        11.5750, 48.1500, '+49 89 22334405', 'kontakt@universitaets-demo.de', 'https://universitaets-demo.medimap.local',
        '{"mon":[["08:00","19:30"]],"tue":[["08:00","19:30"]],"wed":[["08:00","19:30"]],"thu":[["08:00","19:30"]],"fri":[["08:00","19:30"]],"sat":[["09:00","16:00"]],"sun":[]}'),
    ('bogenhausen@demo.medimap',  'Prinzregenten-Apotheke',       'Prinzregentenstr. 60, 81675 München',
        11.6030, 48.1450, '+49 89 22334406', 'kontakt@prinzregenten-demo.de', 'https://prinzregenten-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","14:00"]],"sun":[]}')
) AS v(owner_email, name, address, lng, lat, phone, email, website, opening_hours)
JOIN users u ON u.email = v.owner_email
ON CONFLICT (user_id) DO NOTHING;

-- Stock: curated per pharmacy so search results vary. Overlaps intentionally so a
-- single medicine still returns several Munich pharmacies.
WITH ph AS (
    SELECT p.id, u.email
    FROM pharmacies p JOIN users u ON u.id = p.user_id
    WHERE u.email IN (
        'marienplatz@demo.medimap',
        'schwabing@demo.medimap',
        'haidhausen@demo.medimap',
        'sendling@demo.medimap',
        'maxvorstadt@demo.medimap',
        'bogenhausen@demo.medimap'
    )
),
med AS (
    SELECT id, name, strength FROM medicines
),
stock(owner_email, med_name, med_strength, qty) AS (VALUES
    -- Marienplatz: flagship tourist-central, broad OTC
    ('marienplatz@demo.medimap',  'Aspirin',        '500 mg',  55),
    ('marienplatz@demo.medimap',  'Aspirin Complex','500 mg',  30),
    ('marienplatz@demo.medimap',  'Ibuprofen',      '400 mg',  70),
    ('marienplatz@demo.medimap',  'Paracetamol',    '500 mg',  60),
    ('marienplatz@demo.medimap',  'Cetirizin',      '10 mg',   40),
    ('marienplatz@demo.medimap',  'Bepanthen',      '50 mg/g', 20),
    ('marienplatz@demo.medimap',  'Voltaren Schmerzgel','11.6 mg/g', 25),

    -- Schwabing: student area, cold/flu and allergy focus
    ('schwabing@demo.medimap',    'Ibuprofen',      '400 mg',  50),
    ('schwabing@demo.medimap',    'ACC akut',       '600 mg',  35),
    ('schwabing@demo.medimap',    'Sinupret',       'combination', 30),
    ('schwabing@demo.medimap',    'Lorano',         '10 mg',   28),
    ('schwabing@demo.medimap',    'Aerius',         '5 mg',    18),
    ('schwabing@demo.medimap',    'Nurofen',        '400 mg',  22),

    -- Haidhausen: family neighbourhood
    ('haidhausen@demo.medimap',   'ben-u-ron',      '500 mg',  30),
    ('haidhausen@demo.medimap',   'Paracetamol',    '500 mg',  45),
    ('haidhausen@demo.medimap',   'Ibuprofen',      '200 mg',  40),
    ('haidhausen@demo.medimap',   'Fenistil Gel',   '1 mg/g',  20),
    ('haidhausen@demo.medimap',   'Vigantoletten',  '1000 IU', 25),
    ('haidhausen@demo.medimap',   'Mucosolvan',     '30 mg',   18),

    -- Sendling: mixed, incl. Rx staples
    ('sendling@demo.medimap',     'Ibuprofen',      '600 mg',  35),
    ('sendling@demo.medimap',     'Novalgin',       '500 mg',  20),
    ('sendling@demo.medimap',     'Amoxicillin',    '500 mg',  15),
    ('sendling@demo.medimap',     'Metformin',      '500 mg',  22),
    ('sendling@demo.medimap',     'Ramipril',       '5 mg',    16),
    ('sendling@demo.medimap',     'Pantoprazol',    '40 mg',   18),

    -- Maxvorstadt: uni district, GI + psychotropic on-hand
    ('maxvorstadt@demo.medimap',  'Pantoprazol',    '20 mg',   30),
    ('maxvorstadt@demo.medimap',  'Omeprazol',      '20 mg',   25),
    ('maxvorstadt@demo.medimap',  'Buscopan',       '10 mg',   18),
    ('maxvorstadt@demo.medimap',  'Sertralin',      '50 mg',   14),
    ('maxvorstadt@demo.medimap',  'Ibuprofen',      '400 mg',  45),
    ('maxvorstadt@demo.medimap',  'Iberogast',      'combination', 20),

    -- Bogenhausen: affluent, cardio / lifestyle
    ('bogenhausen@demo.medimap',  'ASS 100',        '100 mg',  35),
    ('bogenhausen@demo.medimap',  'Simvastatin',    '20 mg',   28),
    ('bogenhausen@demo.medimap',  'Atorvastatin',   '20 mg',   30),
    ('bogenhausen@demo.medimap',  'Bisoprolol',     '5 mg',    20),
    ('bogenhausen@demo.medimap',  'Amlodipin',      '5 mg',    18),
    ('bogenhausen@demo.medimap',  'L-Thyroxin',     '100 µg',  22),
    ('bogenhausen@demo.medimap',  'Magnesium 400',  '400 mg',  30)
)
INSERT INTO pharmacy_stock (pharmacy_id, medicine_id, quantity)
SELECT ph.id, med.id, stock.qty
FROM stock
JOIN ph ON ph.email = stock.owner_email
JOIN med ON med.name = stock.med_name AND med.strength = stock.med_strength
ON CONFLICT (pharmacy_id, medicine_id) DO UPDATE SET quantity = EXCLUDED.quantity;
