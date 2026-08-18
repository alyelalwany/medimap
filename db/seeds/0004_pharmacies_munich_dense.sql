-- Dense Munich pharmacy seed. Idempotent: safe to re-run.
-- Adds ~30 more pharmacies across Munich and surrounding districts so common
-- OTC searches (Ibuprofen 400 mg, Paracetamol 500 mg, Aspirin, Cetirizin) return
-- many overlapping results, which is what a real city map looks like.
-- All demo pharmacy users share the password "demo1234".

-- Insert users (pharmacy owners). password_hash = bcrypt("demo1234").
INSERT INTO users (email, password_hash, role) VALUES
    ('altstadt2@demo.medimap',     '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('altstadt3@demo.medimap',     '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('hauptbahnhof@demo.medimap',  '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('ludwigsvorstadt@demo.medimap','$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('isarvorstadt@demo.medimap',  '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('glockenbach@demo.medimap',   '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('gaertnerplatz@demo.medimap', '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('maxvorstadt2@demo.medimap',  '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('maxvorstadt3@demo.medimap',  '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('schwabing2@demo.medimap',    '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('schwabing3@demo.medimap',    '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('schwabing4@demo.medimap',    '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('milbertshofen@demo.medimap', '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('freimann@demo.medimap',      '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('bogenhausen2@demo.medimap',  '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('bogenhausen3@demo.medimap',  '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('haidhausen2@demo.medimap',   '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('haidhausen3@demo.medimap',   '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('berg-am-laim@demo.medimap',  '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('ramersdorf@demo.medimap',    '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('giesing@demo.medimap',       '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('sendling2@demo.medimap',     '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('westend@demo.medimap',       '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('laim@demo.medimap',          '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('pasing@demo.medimap',        '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('nymphenburg@demo.medimap',   '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('neuhausen@demo.medimap',     '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('moosach@demo.medimap',       '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('obermenzing@demo.medimap',   '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy'),
    ('thalkirchen@demo.medimap',   '$2a$10$dGZfSfgE/n535A2XwJXGYeV2BP.X1dBYhMMsyVZ5upAOrShkic5yO', 'pharmacy')
ON CONFLICT (email) DO NOTHING;

-- Insert pharmacies. Coordinates spread across real Munich districts.
INSERT INTO pharmacies (user_id, name, address, location, phone, email, website, opening_hours)
SELECT u.id, v.name, v.address,
       ST_SetSRID(ST_MakePoint(v.lng, v.lat), 4326)::geography,
       v.phone, v.email, v.website, v.opening_hours::jsonb
FROM (VALUES
    ('altstadt2@demo.medimap',      'Rathaus-Apotheke',           'Marienplatz 8, 80331 München',
        11.5765, 48.1374, '+49 89 22334420', 'kontakt@rathaus-demo.de',       'https://rathaus-demo.medimap.local',
        '{"mon":[["08:00","20:00"]],"tue":[["08:00","20:00"]],"wed":[["08:00","20:00"]],"thu":[["08:00","20:00"]],"fri":[["08:00","20:00"]],"sat":[["09:00","18:00"]],"sun":[]}'),
    ('altstadt3@demo.medimap',      'Frauenkirche-Apotheke',      'Kaufingerstr. 15, 80331 München',
        11.5735, 48.1385, '+49 89 22334421', 'kontakt@frauenkirche-demo.de',  'https://frauenkirche-demo.medimap.local',
        '{"mon":[["08:30","19:30"]],"tue":[["08:30","19:30"]],"wed":[["08:30","19:30"]],"thu":[["08:30","19:30"]],"fri":[["08:30","19:30"]],"sat":[["09:00","18:00"]],"sun":[]}'),
    ('hauptbahnhof@demo.medimap',   'Bahnhof-Apotheke',           'Bayerstr. 5, 80335 München',
        11.5580, 48.1400, '+49 89 22334422', 'kontakt@bahnhof-demo.de',       'https://bahnhof-demo.medimap.local',
        '{"mon":[["06:30","22:00"]],"tue":[["06:30","22:00"]],"wed":[["06:30","22:00"]],"thu":[["06:30","22:00"]],"fri":[["06:30","22:00"]],"sat":[["07:00","22:00"]],"sun":[["08:00","20:00"]]}'),
    ('ludwigsvorstadt@demo.medimap','Theresien-Apotheke',         'Landwehrstr. 22, 80336 München',
        11.5620, 48.1360, '+49 89 22334423', 'kontakt@theresien-demo.de',     'https://theresien-demo.medimap.local',
        '{"mon":[["08:00","19:00"]],"tue":[["08:00","19:00"]],"wed":[["08:00","19:00"]],"thu":[["08:00","19:00"]],"fri":[["08:00","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('isarvorstadt@demo.medimap',   'Deutsches Museum-Apotheke',  'Erhardtstr. 8, 80469 München',
        11.5820, 48.1310, '+49 89 22334424', 'kontakt@museum-demo.de',        'https://museum-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('glockenbach@demo.medimap',    'Müllerstraßen-Apotheke',     'Müllerstr. 40, 80469 München',
        11.5710, 48.1315, '+49 89 22334425', 'kontakt@mueller-demo.de',       'https://mueller-demo.medimap.local',
        '{"mon":[["08:00","19:00"]],"tue":[["08:00","19:00"]],"wed":[["08:00","19:00"]],"thu":[["08:00","19:00"]],"fri":[["08:00","19:00"]],"sat":[["09:00","16:00"]],"sun":[]}'),
    ('gaertnerplatz@demo.medimap',  'Gärtnerplatz-Apotheke',      'Gärtnerplatz 3, 80469 München',
        11.5750, 48.1330, '+49 89 22334426', 'kontakt@gaertner-demo.de',      'https://gaertner-demo.medimap.local',
        '{"mon":[["08:30","19:00"]],"tue":[["08:30","19:00"]],"wed":[["08:30","19:00"]],"thu":[["08:30","19:00"]],"fri":[["08:30","19:00"]],"sat":[["09:00","16:00"]],"sun":[]}'),
    ('maxvorstadt2@demo.medimap',   'Pinakotheken-Apotheke',      'Barer Str. 30, 80333 München',
        11.5710, 48.1490, '+49 89 22334427', 'kontakt@pinakothek-demo.de',    'https://pinakothek-demo.medimap.local',
        '{"mon":[["08:30","19:00"]],"tue":[["08:30","19:00"]],"wed":[["08:30","19:00"]],"thu":[["08:30","19:00"]],"fri":[["08:30","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('maxvorstadt3@demo.medimap',   'Königsplatz-Apotheke',       'Brienner Str. 45, 80333 München',
        11.5665, 48.1470, '+49 89 22334428', 'kontakt@koenigsplatz-demo.de',  'https://koenigsplatz-demo.medimap.local',
        '{"mon":[["08:00","19:00"]],"tue":[["08:00","19:00"]],"wed":[["08:00","19:00"]],"thu":[["08:00","19:00"]],"fri":[["08:00","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('schwabing2@demo.medimap',     'Münchner Freiheit-Apotheke', 'Leopoldstr. 82, 80802 München',
        11.5870, 48.1660, '+49 89 22334429', 'kontakt@freiheit-demo.de',      'https://freiheit-demo.medimap.local',
        '{"mon":[["08:00","20:00"]],"tue":[["08:00","20:00"]],"wed":[["08:00","20:00"]],"thu":[["08:00","20:00"]],"fri":[["08:00","20:00"]],"sat":[["09:00","18:00"]],"sun":[]}'),
    ('schwabing3@demo.medimap',     'Elisabethmarkt-Apotheke',    'Elisabethstr. 25, 80796 München',
        11.5790, 48.1590, '+49 89 22334430', 'kontakt@elisabeth-demo.de',     'https://elisabeth-demo.medimap.local',
        '{"mon":[["08:30","19:00"]],"tue":[["08:30","19:00"]],"wed":[["08:30","19:00"]],"thu":[["08:30","19:00"]],"fri":[["08:30","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('schwabing4@demo.medimap',     'Nordbad-Apotheke',           'Schleißheimer Str. 142, 80797 München',
        11.5680, 48.1620, '+49 89 22334431', 'kontakt@nordbad-demo.de',       'https://nordbad-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","13:00"]],"sun":[]}'),
    ('milbertshofen@demo.medimap',  'Frankfurter Ring-Apotheke',  'Frankfurter Ring 193, 80807 München',
        11.5730, 48.1900, '+49 89 22334432', 'kontakt@frankfurter-demo.de',   'https://frankfurter-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","13:00"]],"sun":[]}'),
    ('freimann@demo.medimap',       'Studentenstadt-Apotheke',    'Ungererstr. 220, 80805 München',
        11.6030, 48.1830, '+49 89 22334433', 'kontakt@studentenstadt-demo.de','https://studentenstadt-demo.medimap.local',
        '{"mon":[["08:30","19:00"]],"tue":[["08:30","19:00"]],"wed":[["08:30","19:00"]],"thu":[["08:30","19:00"]],"fri":[["08:30","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('bogenhausen2@demo.medimap',   'Herkomer-Apotheke',          'Herkomerplatz 2, 81679 München',
        11.6110, 48.1560, '+49 89 22334434', 'kontakt@herkomer-demo.de',      'https://herkomer-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('bogenhausen3@demo.medimap',   'Arabellapark-Apotheke',      'Rosenkavalierplatz 3, 81925 München',
        11.6210, 48.1620, '+49 89 22334435', 'kontakt@arabella-demo.de',      'https://arabella-demo.medimap.local',
        '{"mon":[["08:00","19:00"]],"tue":[["08:00","19:00"]],"wed":[["08:00","19:00"]],"thu":[["08:00","19:00"]],"fri":[["08:00","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('haidhausen2@demo.medimap',    'Ostbahnhof-Apotheke',        'Orleansstr. 45, 81667 München',
        11.6020, 48.1270, '+49 89 22334436', 'kontakt@ostbahnhof-demo.de',    'https://ostbahnhof-demo.medimap.local',
        '{"mon":[["07:30","20:00"]],"tue":[["07:30","20:00"]],"wed":[["07:30","20:00"]],"thu":[["07:30","20:00"]],"fri":[["07:30","20:00"]],"sat":[["08:00","18:00"]],"sun":[]}'),
    ('haidhausen3@demo.medimap',    'Max-Weber-Platz-Apotheke',   'Max-Weber-Platz 4, 81675 München',
        11.5990, 48.1360, '+49 89 22334437', 'kontakt@weberplatz-demo.de',    'https://weberplatz-demo.medimap.local',
        '{"mon":[["08:00","18:30"]],"tue":[["08:00","18:30"]],"wed":[["08:00","18:30"]],"thu":[["08:00","18:30"]],"fri":[["08:00","18:30"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('berg-am-laim@demo.medimap',   'Berg-am-Laim-Apotheke',      'Kreillerstr. 200, 81825 München',
        11.6420, 48.1290, '+49 89 22334438', 'kontakt@laim-demo.de',          'https://berglaim-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","13:00"]],"sun":[]}'),
    ('ramersdorf@demo.medimap',     'Ramersdorf-Apotheke',        'Rosenheimer Str. 210, 81669 München',
        11.6180, 48.1150, '+49 89 22334439', 'kontakt@ramersdorf-demo.de',    'https://ramersdorf-demo.medimap.local',
        '{"mon":[["08:00","18:30"]],"tue":[["08:00","18:30"]],"wed":[["08:00","18:30"]],"thu":[["08:00","18:30"]],"fri":[["08:00","18:30"]],"sat":[["09:00","13:00"]],"sun":[]}'),
    ('giesing@demo.medimap',        'Giesinger Berg-Apotheke',    'Tegernseer Landstr. 92, 81539 München',
        11.5820, 48.1140, '+49 89 22334440', 'kontakt@giesing-demo.de',       'https://giesing-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","13:00"]],"sun":[]}'),
    ('sendling2@demo.medimap',      'Harras-Apotheke',            'Plinganserstr. 8, 81369 München',
        11.5410, 48.1170, '+49 89 22334441', 'kontakt@harras-demo.de',        'https://harras-demo.medimap.local',
        '{"mon":[["08:00","19:00"]],"tue":[["08:00","19:00"]],"wed":[["08:00","19:00"]],"thu":[["08:00","19:00"]],"fri":[["08:00","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('westend@demo.medimap',        'Westend-Apotheke',           'Landsberger Str. 190, 80687 München',
        11.5280, 48.1400, '+49 89 22334442', 'kontakt@westend-demo.de',       'https://westend-demo.medimap.local',
        '{"mon":[["08:00","19:00"]],"tue":[["08:00","19:00"]],"wed":[["08:00","19:00"]],"thu":[["08:00","19:00"]],"fri":[["08:00","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('laim@demo.medimap',           'Laim-Apotheke',              'Fürstenrieder Str. 30, 80686 München',
        11.5120, 48.1420, '+49 89 22334443', 'kontakt@laimhood-demo.de',      'https://laim-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","13:00"]],"sun":[]}'),
    ('pasing@demo.medimap',         'Pasinger Marienplatz-Apotheke','Bäckerstr. 10, 81241 München',
        11.4620, 48.1490, '+49 89 22334444', 'kontakt@pasing-demo.de',        'https://pasing-demo.medimap.local',
        '{"mon":[["08:00","19:00"]],"tue":[["08:00","19:00"]],"wed":[["08:00","19:00"]],"thu":[["08:00","19:00"]],"fri":[["08:00","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('nymphenburg@demo.medimap',    'Nymphenburger Schloss-Apotheke','Notburgastr. 3, 80639 München',
        11.5110, 48.1560, '+49 89 22334445', 'kontakt@nymphenburg-demo.de',   'https://nymphenburg-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","13:00"]],"sun":[]}'),
    ('neuhausen@demo.medimap',      'Rotkreuzplatz-Apotheke',     'Rotkreuzplatz 8, 80634 München',
        11.5370, 48.1520, '+49 89 22334446', 'kontakt@rotkreuz-demo.de',      'https://rotkreuz-demo.medimap.local',
        '{"mon":[["08:00","19:00"]],"tue":[["08:00","19:00"]],"wed":[["08:00","19:00"]],"thu":[["08:00","19:00"]],"fri":[["08:00","19:00"]],"sat":[["09:00","14:00"]],"sun":[]}'),
    ('moosach@demo.medimap',        'Moosacher St.-Martins-Apotheke','Moosacher St.-Martins-Platz 5, 80809 München',
        11.5390, 48.1810, '+49 89 22334447', 'kontakt@moosach-demo.de',       'https://moosach-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","13:00"]],"sun":[]}'),
    ('obermenzing@demo.medimap',    'Obermenzing-Apotheke',       'Verdistr. 42, 81247 München',
        11.4770, 48.1650, '+49 89 22334448', 'kontakt@obermenzing-demo.de',   'https://obermenzing-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","13:00"]],"sun":[]}'),
    ('thalkirchen@demo.medimap',    'Tierpark-Apotheke',          'Tierparkstr. 40, 81543 München',
        11.5490, 48.0990, '+49 89 22334449', 'kontakt@tierpark-demo.de',      'https://tierpark-demo.medimap.local',
        '{"mon":[["08:30","18:30"]],"tue":[["08:30","18:30"]],"wed":[["08:30","18:30"]],"thu":[["08:30","18:30"]],"fri":[["08:30","18:30"]],"sat":[["09:00","13:00"]],"sun":[]}')
) AS v(owner_email, name, address, lng, lat, phone, email, website, opening_hours)
JOIN users u ON u.email = v.owner_email
ON CONFLICT (user_id) DO NOTHING;

-- Stock: give EVERY new pharmacy the top-tier common OTCs, plus a district-flavoured
-- long tail. This means an "Ibuprofen 400 mg" search returns ~30 pharmacies around
-- Munich, like a real map would.
--
-- The common set is: Ibuprofen 400 mg, Paracetamol 500 mg, Aspirin 500 mg,
-- Cetirizin 10 mg, Ibuprofen 200 mg, ASS 100 mg, Pantoprazol 20 mg, Bepanthen.
WITH ph AS (
    SELECT p.id, u.email
    FROM pharmacies p JOIN users u ON u.id = p.user_id
    WHERE u.email IN (
        'altstadt2@demo.medimap','altstadt3@demo.medimap','hauptbahnhof@demo.medimap',
        'ludwigsvorstadt@demo.medimap','isarvorstadt@demo.medimap','glockenbach@demo.medimap',
        'gaertnerplatz@demo.medimap','maxvorstadt2@demo.medimap','maxvorstadt3@demo.medimap',
        'schwabing2@demo.medimap','schwabing3@demo.medimap','schwabing4@demo.medimap',
        'milbertshofen@demo.medimap','freimann@demo.medimap','bogenhausen2@demo.medimap',
        'bogenhausen3@demo.medimap','haidhausen2@demo.medimap','haidhausen3@demo.medimap',
        'berg-am-laim@demo.medimap','ramersdorf@demo.medimap','giesing@demo.medimap',
        'sendling2@demo.medimap','westend@demo.medimap','laim@demo.medimap',
        'pasing@demo.medimap','nymphenburg@demo.medimap','neuhausen@demo.medimap',
        'moosach@demo.medimap','obermenzing@demo.medimap','thalkirchen@demo.medimap'
    )
),
med AS (
    SELECT id, name, strength FROM medicines
),
-- Common OTCs every pharmacy carries. Quantity varies so results feel realistic.
common_stock AS (
    SELECT p.email, m.name AS med_name, m.strength AS med_strength,
           -- pseudo-random qty in [12, 80] derived from md5 of (email + med) to
           -- stay deterministic across seeds.
           12 + (('x' || substr(md5(p.email || m.name || m.strength), 1, 4))::bit(16)::int % 69) AS qty
    FROM ph p
    CROSS JOIN (VALUES
        ('Ibuprofen',   '400 mg'),
        ('Ibuprofen',   '200 mg'),
        ('Ibuprofen',   '600 mg'),
        ('Paracetamol', '500 mg'),
        ('Paracetamol', '1000 mg'),
        ('Aspirin',     '500 mg'),
        ('Cetirizin',   '10 mg'),
        ('ASS 100',     '100 mg'),
        ('Pantoprazol', '20 mg'),
        ('Bepanthen',   '50 mg/g')
    ) AS c(med_name, med_strength)
    JOIN medicines m ON m.name = c.med_name AND m.strength = c.med_strength
),
-- District-flavoured extras (Rx staples, allergy, cardio, GI).
extra_stock(owner_email, med_name, med_strength, qty) AS (VALUES
    ('altstadt2@demo.medimap',      'Voltaren Schmerzgel', '11.6 mg/g', 26),
    ('altstadt2@demo.medimap',      'Nurofen',             '400 mg',    32),
    ('altstadt3@demo.medimap',      'Aspirin Complex',     '500 mg',    24),
    ('altstadt3@demo.medimap',      'Sinupret',            'combination', 30),
    ('hauptbahnhof@demo.medimap',   'Wick MediNait',       'combination', 20),
    ('hauptbahnhof@demo.medimap',   'ACC akut',            '600 mg',    28),
    ('hauptbahnhof@demo.medimap',   'Fenistil Gel',        '1 mg/g',    18),
    ('hauptbahnhof@demo.medimap',   'Imodium',             '2 mg',      22),
    ('ludwigsvorstadt@demo.medimap','Amoxicillin',         '500 mg',    18),
    ('ludwigsvorstadt@demo.medimap','Ciprofloxacin',       '500 mg',    12),
    ('isarvorstadt@demo.medimap',   'Novalgin',            '500 mg',    22),
    ('isarvorstadt@demo.medimap',   'Buscopan',            '10 mg',     16),
    ('glockenbach@demo.medimap',    'Iberogast',           'combination', 20),
    ('glockenbach@demo.medimap',    'Omeprazol',           '20 mg',     22),
    ('gaertnerplatz@demo.medimap',  'Lorano',              '10 mg',     28),
    ('gaertnerplatz@demo.medimap',  'Aerius',              '5 mg',      18),
    ('maxvorstadt2@demo.medimap',   'Sertralin',           '50 mg',     14),
    ('maxvorstadt2@demo.medimap',   'Vigantoletten',       '1000 IU',   30),
    ('maxvorstadt3@demo.medimap',   'Magnesium 400',       '400 mg',    28),
    ('maxvorstadt3@demo.medimap',   'Zink 25',             '25 mg',     22),
    ('schwabing2@demo.medimap',     'Mucosolvan',          '30 mg',     20),
    ('schwabing2@demo.medimap',     'Nurofen',             '400 mg',    24),
    ('schwabing3@demo.medimap',     'ben-u-ron',           '500 mg',    26),
    ('schwabing3@demo.medimap',     'Fenistil Gel',        '1 mg/g',    18),
    ('schwabing4@demo.medimap',     'Vigantoletten',       '1000 IU',   26),
    ('schwabing4@demo.medimap',     'L-Thyroxin',          '50 µg',     20),
    ('milbertshofen@demo.medimap',  'Metformin',           '500 mg',    22),
    ('milbertshofen@demo.medimap',  'Ramipril',            '5 mg',      18),
    ('freimann@demo.medimap',       'Sertralin',           '100 mg',    12),
    ('freimann@demo.medimap',       'Buscopan',            '10 mg',     16),
    ('bogenhausen2@demo.medimap',   'Simvastatin',         '20 mg',     24),
    ('bogenhausen2@demo.medimap',   'Atorvastatin',        '20 mg',     26),
    ('bogenhausen3@demo.medimap',   'Bisoprolol',          '5 mg',      20),
    ('bogenhausen3@demo.medimap',   'Amlodipin',           '5 mg',      18),
    ('bogenhausen3@demo.medimap',   'L-Thyroxin',          '100 µg',    22),
    ('haidhausen2@demo.medimap',    'Ramipril',            '10 mg',     18),
    ('haidhausen2@demo.medimap',    'ACC akut',            '600 mg',    22),
    ('haidhausen3@demo.medimap',    'Novalgin',            '500 mg',    18),
    ('haidhausen3@demo.medimap',    'Voltaren',            '50 mg',     20),
    ('berg-am-laim@demo.medimap',   'Metformin',           '1000 mg',   18),
    ('berg-am-laim@demo.medimap',   'Amlodipin',           '5 mg',      16),
    ('ramersdorf@demo.medimap',     'Voltaren',            '25 mg',     18),
    ('ramersdorf@demo.medimap',     'Hydrocortison',       '5 mg/g',    12),
    ('giesing@demo.medimap',        'Ibuprofen',           '600 mg',    24),
    ('giesing@demo.medimap',        'Imodium',             '2 mg',      16),
    ('sendling2@demo.medimap',      'ASS 100',             '100 mg',    28),
    ('sendling2@demo.medimap',      'Simvastatin',         '20 mg',     20),
    ('westend@demo.medimap',        'Amoxicillin',         '1000 mg',   14),
    ('westend@demo.medimap',        'Azithromycin',        '500 mg',    12),
    ('laim@demo.medimap',           'Lorano',              '10 mg',     22),
    ('laim@demo.medimap',           'Bepanthen',           '50 mg/g',   18),
    ('pasing@demo.medimap',         'Sinupret',            'combination', 24),
    ('pasing@demo.medimap',         'Mucosolvan',          '30 mg',     20),
    ('nymphenburg@demo.medimap',    'Magnesium 400',       '400 mg',    26),
    ('nymphenburg@demo.medimap',    'Vigantoletten',       '1000 IU',   22),
    ('neuhausen@demo.medimap',      'Voltaren Schmerzgel', '11.6 mg/g', 22),
    ('neuhausen@demo.medimap',      'Fenistil Gel',        '1 mg/g',    18),
    ('moosach@demo.medimap',        'Iberogast',           'combination', 16),
    ('moosach@demo.medimap',        'Omeprazol',           '20 mg',     20),
    ('obermenzing@demo.medimap',    'Bisoprolol',          '5 mg',      18),
    ('obermenzing@demo.medimap',    'Metoprolol',          '50 mg',     16),
    ('thalkirchen@demo.medimap',    'Cetirizin',           '10 mg',     22),
    ('thalkirchen@demo.medimap',    'Aerius',              '5 mg',      18)
),
merged AS (
    -- Extras override common qty when the same (pharmacy, medicine) appears in both.
    SELECT owner_email, med_name, med_strength, qty FROM extra_stock
    UNION ALL
    SELECT c.email, c.med_name, c.med_strength, c.qty
    FROM common_stock c
    WHERE NOT EXISTS (
        SELECT 1 FROM extra_stock e
        WHERE e.owner_email = c.email
          AND e.med_name = c.med_name
          AND e.med_strength = c.med_strength
    )
)
INSERT INTO pharmacy_stock (pharmacy_id, medicine_id, quantity)
SELECT ph.id, med.id, merged.qty
FROM merged
JOIN ph  ON ph.email = merged.owner_email
JOIN med ON med.name = merged.med_name AND med.strength = merged.med_strength
ON CONFLICT (pharmacy_id, medicine_id) DO UPDATE SET quantity = EXCLUDED.quantity;
