-- Seed demo pharmacies + stock. Idempotent: safe to re-run.
-- All demo pharmacy users share the password "demo1234".
-- Coordinates are around Berlin so the default map view shows them.

-- Insert users (pharmacy owners). password_hash = bcrypt("demo1234").
INSERT INTO users (email, password_hash, role) VALUES
    ('mitte@demo.medimap',       '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('prenzlauer@demo.medimap',  '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('kreuzberg@demo.medimap',   '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('friedrichshain@demo.medimap','$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('charlottenburg@demo.medimap','$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('neukoelln@demo.medimap',   '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy')
ON CONFLICT (email) DO NOTHING;

-- Insert pharmacies referencing the users above. Match by owner email so re-runs are safe.
INSERT INTO pharmacies (user_id, name, address, location, phone, email, website, opening_hours)
SELECT u.id, v.name, v.address,
       ST_SetSRID(ST_MakePoint(v.lng, v.lat), 4326)::geography,
       v.phone, v.email, v.website, v.opening_hours::jsonb
FROM (VALUES
    ('mitte@demo.medimap',        'Apotheke am Hackeschen Markt', 'Rosenthaler Str. 40, 10178 Berlin',
        13.4022, 52.5237, '+49 30 12345601', 'kontakt@mitte-demo.de', 'https://mitte-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('prenzlauer@demo.medimap',   'Kastanien-Apotheke',           'Kastanienallee 12, 10435 Berlin',
        13.4090, 52.5350, '+49 30 12345602', 'kontakt@kastanien-demo.de', 'https://kastanien-demo.medimap.local',
        '{"mon":[["09:00","19:00"]],"tue":[["09:00","19:00"]],"wed":[["09:00","19:00"]],"thu":[["09:00","19:00"]],"fri":[["09:00","19:00"]],"sat":[["09:00","16:00"]],"sun":[]}'),
    ('kreuzberg@demo.medimap',    'Bergmann-Apotheke',            'Bergmannstr. 5, 10961 Berlin',
        13.3970, 52.4900, '+49 30 12345603', 'kontakt@bergmann-demo.de', 'https://bergmann-demo.medimap.local',
        '{"mon":[["08:00","20:00"]],"tue":[["08:00","20:00"]],"wed":[["08:00","20:00"]],"thu":[["08:00","20:00"]],"fri":[["08:00","20:00"]],"sat":[["09:00","18:00"]],"sun":[]}'),
    ('friedrichshain@demo.medimap','Boxhagener Apotheke',         'Boxhagener Str. 76, 10245 Berlin',
        13.4640, 52.5100, '+49 30 12345604', 'kontakt@boxhagener-demo.de', 'https://boxhagener-demo.medimap.local',
        '{"mon":[["08:30","19:00"]],"tue":[["08:30","19:00"]],"wed":[["08:30","19:00"]],"thu":[["08:30","19:00"]],"fri":[["08:30","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('charlottenburg@demo.medimap','Kurfürstendamm-Apotheke',     'Kurfürstendamm 190, 10707 Berlin',
        13.3200, 52.5010, '+49 30 12345605', 'kontakt@kudamm-demo.de', 'https://kudamm-demo.medimap.local',
        '{"mon":[["08:00","20:00"]],"tue":[["08:00","20:00"]],"wed":[["08:00","20:00"]],"thu":[["08:00","20:00"]],"fri":[["08:00","20:00"]],"sat":[["09:00","18:00"]],"sun":[["10:00","14:00"]]}'),
    ('neukoelln@demo.medimap',    'Sonnen-Apotheke Neukölln',     'Karl-Marx-Str. 82, 12043 Berlin',
        13.4370, 52.4790, '+49 30 12345606', 'kontakt@sonnen-demo.de', 'https://sonnen-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","13:00"]],"sun":[]}')
) AS v(owner_email, name, address, lng, lat, phone, email, website, opening_hours)
JOIN users u ON u.email = v.owner_email
ON CONFLICT (user_id) DO NOTHING;

-- Stock: give each pharmacy a curated selection so search results vary across medicines.
-- Every insert is idempotent via ON CONFLICT.
WITH ph AS (
    SELECT p.id, u.email
    FROM pharmacies p JOIN users u ON u.id = p.user_id
    WHERE u.email LIKE '%@demo.medimap'
),
med AS (
    SELECT id, name, strength FROM medicines
),
stock(owner_email, med_name, med_strength, qty) AS (VALUES
    -- Mitte: general OTC, well stocked
    ('mitte@demo.medimap',        'Aspirin',      '500 mg',  40),
    ('mitte@demo.medimap',        'Ibuprofen',    '400 mg',  60),
    ('mitte@demo.medimap',        'Ibuprofen',    '600 mg',  25),
    ('mitte@demo.medimap',        'Paracetamol',  '500 mg',  50),
    ('mitte@demo.medimap',        'Cetirizin',    '10 mg',   30),
    ('mitte@demo.medimap',        'Pantoprazol',  '20 mg',   20),
    ('mitte@demo.medimap',        'Bepanthen',    '50 mg/g', 15),

    -- Prenzlauer Berg: skews family / paediatric-friendly
    ('prenzlauer@demo.medimap',   'ben-u-ron',    '500 mg',  35),
    ('prenzlauer@demo.medimap',   'Paracetamol',  '500 mg',  40),
    ('prenzlauer@demo.medimap',   'Ibuprofen',    '400 mg',  45),
    ('prenzlauer@demo.medimap',   'Nurofen',      '400 mg',  20),
    ('prenzlauer@demo.medimap',   'Fenistil Gel', '1 mg/g',  18),
    ('prenzlauer@demo.medimap',   'Vigantoletten','1000 IU', 30),

    -- Kreuzberg: broad, includes Rx-style
    ('kreuzberg@demo.medimap',    'Ibuprofen',    '400 mg',  55),
    ('kreuzberg@demo.medimap',    'Novalgin',     '500 mg',  22),
    ('kreuzberg@demo.medimap',    'Amoxicillin',  '500 mg',  12),
    ('kreuzberg@demo.medimap',    'Ramipril',     '5 mg',    18),
    ('kreuzberg@demo.medimap',    'Metformin',    '500 mg',  25),
    ('kreuzberg@demo.medimap',    'L-Thyroxin',   '50 µg',   20),

    -- Friedrichshain: cold/flu heavy
    ('friedrichshain@demo.medimap','Aspirin Complex','500 mg', 28),
    ('friedrichshain@demo.medimap','ACC akut',    '600 mg',  30),
    ('friedrichshain@demo.medimap','Mucosolvan',  '30 mg',   24),
    ('friedrichshain@demo.medimap','Sinupret',    'combination', 40),
    ('friedrichshain@demo.medimap','Ibuprofen',   '200 mg',  50),
    ('friedrichshain@demo.medimap','Wick MediNait','combination', 15),

    -- Charlottenburg: cardio / lifestyle
    ('charlottenburg@demo.medimap','ASS 100',     '100 mg',  40),
    ('charlottenburg@demo.medimap','Simvastatin', '20 mg',   30),
    ('charlottenburg@demo.medimap','Atorvastatin','20 mg',   28),
    ('charlottenburg@demo.medimap','Bisoprolol',  '5 mg',    22),
    ('charlottenburg@demo.medimap','Amlodipin',   '5 mg',    18),
    ('charlottenburg@demo.medimap','Magnesium 400','400 mg', 35),

    -- Neukölln: budget essentials
    ('neukoelln@demo.medimap',    'Paracetamol',  '500 mg',  60),
    ('neukoelln@demo.medimap',    'Ibuprofen',    '400 mg',  50),
    ('neukoelln@demo.medimap',    'Cetirizin',    '10 mg',   25),
    ('neukoelln@demo.medimap',    'Imodium',      '2 mg',    18),
    ('neukoelln@demo.medimap',    'Buscopan',     '10 mg',   14),
    ('neukoelln@demo.medimap',    'Zink 25',      '25 mg',   22)
)
INSERT INTO pharmacy_stock (pharmacy_id, medicine_id, quantity)
SELECT ph.id, med.id, stock.qty
FROM stock
JOIN ph ON ph.email = stock.owner_email
JOIN med ON med.name = stock.med_name AND med.strength = stock.med_strength
ON CONFLICT (pharmacy_id, medicine_id) DO UPDATE SET quantity = EXCLUDED.quantity;
