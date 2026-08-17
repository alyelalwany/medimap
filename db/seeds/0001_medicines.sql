-- Seed medicine catalog. Idempotent: safe to re-run.
-- Names are common German/international brands + INN pairs; strengths and forms
-- reflect typical pharmacy SKUs. Not a legal drug database - hand-curated MVP list.

INSERT INTO medicines (name, active_ingredient, strength, form) VALUES
    -- Analgesics / antipyretics
    ('Aspirin',           'acetylsalicylic acid', '500 mg', 'tablet'),
    ('Aspirin Complex',   'acetylsalicylic acid', '500 mg', 'granules'),
    ('Paracetamol',       'paracetamol',          '500 mg', 'tablet'),
    ('Paracetamol',       'paracetamol',          '1000 mg', 'tablet'),
    ('ben-u-ron',         'paracetamol',          '500 mg', 'suppository'),
    ('Ibuprofen',         'ibuprofen',            '200 mg', 'tablet'),
    ('Ibuprofen',         'ibuprofen',            '400 mg', 'tablet'),
    ('Ibuprofen',         'ibuprofen',            '600 mg', 'tablet'),
    ('Nurofen',           'ibuprofen',            '400 mg', 'tablet'),
    ('Voltaren',          'diclofenac',           '25 mg',  'tablet'),
    ('Voltaren',          'diclofenac',           '50 mg',  'tablet'),
    ('Voltaren Schmerzgel','diclofenac',          '11.6 mg/g', 'gel'),
    ('Novalgin',          'metamizole',           '500 mg', 'tablet'),

    -- Cough / cold
    ('Sinupret',          'gentiana + primula + sambucus + rumex + verbena', 'combination', 'tablet'),
    ('GeloMyrtol forte',  'myrtol',               '300 mg', 'capsule'),
    ('ACC akut',          'acetylcysteine',       '600 mg', 'effervescent tablet'),
    ('Mucosolvan',        'ambroxol',             '30 mg',  'tablet'),
    ('Wick MediNait',     'paracetamol + doxylamine + dextromethorphan + ephedrine', 'combination', 'syrup'),

    -- Allergy
    ('Cetirizin',         'cetirizine',           '10 mg',  'tablet'),
    ('Lorano',            'loratadine',           '10 mg',  'tablet'),
    ('Aerius',            'desloratadine',        '5 mg',   'tablet'),

    -- GI
    ('Pantoprazol',       'pantoprazole',         '20 mg',  'tablet'),
    ('Pantoprazol',       'pantoprazole',         '40 mg',  'tablet'),
    ('Omeprazol',         'omeprazole',           '20 mg',  'capsule'),
    ('Iberogast',         'iberis amara + peppermint + chamomile', 'combination', 'oral solution'),
    ('Imodium',           'loperamide',           '2 mg',   'capsule'),
    ('Buscopan',          'butylscopolamine',     '10 mg',  'tablet'),

    -- Cardiovascular
    ('Ramipril',          'ramipril',             '5 mg',   'tablet'),
    ('Ramipril',          'ramipril',             '10 mg',  'tablet'),
    ('Amlodipin',         'amlodipine',           '5 mg',   'tablet'),
    ('Bisoprolol',        'bisoprolol',           '5 mg',   'tablet'),
    ('Metoprolol',        'metoprolol',           '50 mg',  'tablet'),
    ('Simvastatin',       'simvastatin',          '20 mg',  'tablet'),
    ('Atorvastatin',      'atorvastatin',         '20 mg',  'tablet'),
    ('ASS 100',           'acetylsalicylic acid', '100 mg', 'tablet'),

    -- Endocrine
    ('L-Thyroxin',        'levothyroxine',        '50 µg',  'tablet'),
    ('L-Thyroxin',        'levothyroxine',        '100 µg', 'tablet'),
    ('Metformin',         'metformin',            '500 mg', 'tablet'),
    ('Metformin',         'metformin',            '1000 mg','tablet'),

    -- Antibiotics (Rx)
    ('Amoxicillin',       'amoxicillin',          '500 mg', 'capsule'),
    ('Amoxicillin',       'amoxicillin',          '1000 mg','tablet'),
    ('Ciprofloxacin',     'ciprofloxacin',        '500 mg', 'tablet'),
    ('Azithromycin',      'azithromycin',         '500 mg', 'tablet'),

    -- Psychotropics (Rx)
    ('Sertralin',         'sertraline',           '50 mg',  'tablet'),
    ('Sertralin',         'sertraline',           '100 mg', 'tablet'),

    -- Contraceptives / hormone (Rx)
    ('Maxim',             'ethinylestradiol + dienogest', 'combination', 'tablet'),

    -- Topicals / dermatology
    ('Fenistil Gel',      'dimetindene',          '1 mg/g', 'gel'),
    ('Bepanthen',         'dexpanthenol',         '50 mg/g','ointment'),
    ('Hydrocortison',     'hydrocortisone',       '5 mg/g', 'cream'),

    -- Vitamins / supplements
    ('Vigantoletten',     'cholecalciferol',      '1000 IU','tablet'),
    ('Magnesium 400',     'magnesium',            '400 mg', 'effervescent tablet'),
    ('Zink 25',           'zinc',                 '25 mg',  'tablet'),

    -- Ophthalmic
    ('Hylo-Comod',        'sodium hyaluronate',   '1 mg/mL','eye drops'),

    -- Antivirals / pandemic-era common
    ('Paxlovid',          'nirmatrelvir + ritonavir', 'combination', 'tablet')
ON CONFLICT (active_ingredient, strength, form) DO NOTHING;
