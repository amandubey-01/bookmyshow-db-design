-- =============================================================================
-- BookMyShow Database Design Assignment
-- File        : sample_data.sql
-- Description : Sample INSERT statements for all tables
-- Database    : MySQL 8.0+
-- Pre-requisite: Run schema.sql first
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Theatre
-- -----------------------------------------------------------------------------
INSERT INTO Theatre (name, address, city, state, pincode, phone) VALUES
    ('PVR Cinemas Forum Mall',   'Forum Mall, Hosur Rd, Koramangala', 'Bengaluru',   'Karnataka',   '560095', '08040904567'),
    ('INOX Lido Mall',           'Lido Mall, 55 MG Road',             'Bengaluru',   'Karnataka',   '560001', '08022212345'),
    ('Cinepolis Nexus Seawoods', 'Nexus Seawoods Mall, Sector 40',    'Navi Mumbai', 'Maharashtra', '400706', '02227720000'),
    ('PVR Phoenix Palassio',     'Phoenix Palassio, Shaheed Path',    'Lucknow',     'Uttar Pradesh','226010','05224012345');

-- -----------------------------------------------------------------------------
-- 2. Screen
-- -----------------------------------------------------------------------------
INSERT INTO Screen (theatre_id, screen_name, screen_type, total_seats) VALUES
    -- PVR Forum Mall (theatre_id = 1)
    (1, 'Screen 1',   '2D',   150),
    (1, 'Screen 2',   '3D',   120),
    (1, 'IMAX Hall',  'IMAX', 200),
    -- INOX Lido Mall (theatre_id = 2)
    (2, 'Screen 1',   '2D',   100),
    (2, 'Screen 2',   '4DX',   80),
    -- Cinepolis Nexus Seawoods (theatre_id = 3)
    (3, 'Screen 1',   '2D',   130),
    (3, 'Screen 2',   '3D',   110),
    -- PVR Phoenix Palassio (theatre_id = 4)
    (4, 'Screen 1',   '2D',   140),
    (4, 'DBOX Hall',  'DBOX', 160);

-- -----------------------------------------------------------------------------
-- 3. Movie
-- -----------------------------------------------------------------------------
INSERT INTO Movie (title, language, genre, duration_min, certification, release_date, description) VALUES
    ('Kalki 2898 AD',  'Telugu', 'Sci-Fi / Action',   181, 'UA', '2024-06-27', 'A futuristic retelling of the Kalki avatar mythology set in a dystopian world.'),
    ('Stree 2',        'Hindi',  'Horror / Comedy',   135, 'UA', '2024-08-15', 'The town of Chanderi faces a terrifying new supernatural threat.'),
    ('Devara',         'Telugu', 'Action / Thriller', 167, 'UA', '2024-09-27', 'A fearless coastal ruler and his son take on a ruthless crime lord.'),
    ('Singham Again',  'Hindi',  'Action',            148, 'UA', '2024-11-01', 'Bajirao Singham returns for his most challenging mission yet.');

-- -----------------------------------------------------------------------------
-- 4. SeatCategory
-- -----------------------------------------------------------------------------
INSERT INTO SeatCategory (category_name, description) VALUES
    ('Silver',   'Standard seating — lower deck, rows A to F'),
    ('Gold',     'Premium seating — centre rows with optimal screen view'),
    ('Platinum', 'Best-view zone — elevated upper premium section'),
    ('Recliner', 'Full-recline luxury seats with extra legroom');

-- -----------------------------------------------------------------------------
-- 5. Show
--    Scheduling movies across screens at PVR Forum Mall (theatre_id = 1)
--    and INOX Lido Mall (theatre_id = 2) for 2025-01-10
-- -----------------------------------------------------------------------------
INSERT INTO `Show` (movie_id, screen_id, show_date, show_time, status) VALUES
    -- PVR Forum Mall — Screen 1 (screen_id = 1), 2D
    (1, 1, '2025-01-10', '09:30:00', 'SCHEDULED'),  -- show_id = 1
    (1, 1, '2025-01-10', '13:00:00', 'SCHEDULED'),  -- show_id = 2
    (1, 1, '2025-01-10', '17:30:00', 'SCHEDULED'),  -- show_id = 3
    -- PVR Forum Mall — IMAX Hall (screen_id = 3)
    (1, 3, '2025-01-10', '11:00:00', 'SCHEDULED'),  -- show_id = 4
    (1, 3, '2025-01-10', '20:00:00', 'SCHEDULED'),  -- show_id = 5
    -- PVR Forum Mall — Screen 2 (screen_id = 2), 3D
    (2, 2, '2025-01-10', '10:00:00', 'SCHEDULED'),  -- show_id = 6
    (2, 2, '2025-01-10', '14:30:00', 'SCHEDULED'),  -- show_id = 7
    -- INOX Lido Mall — Screen 1 (screen_id = 4), 2D
    (3, 4, '2025-01-10', '11:00:00', 'SCHEDULED'),  -- show_id = 8
    (3, 4, '2025-01-10', '15:30:00', 'SCHEDULED'),  -- show_id = 9
    -- INOX Lido Mall — Screen 2 (screen_id = 5), 4DX
    (4, 5, '2025-01-10', '12:00:00', 'SCHEDULED'),  -- show_id = 10
    (4, 5, '2025-01-10', '18:00:00', 'SCHEDULED');  -- show_id = 11

-- -----------------------------------------------------------------------------
-- 6. ShowSeatCategory  (price + available seats per tier per show)
-- -----------------------------------------------------------------------------
INSERT INTO ShowSeatCategory (show_id, category_id, price, available_seats) VALUES
    -- Show 1 (morning 2D) — Silver, Gold, Platinum
    (1,  1, 200.00,  80),
    (1,  2, 350.00,  50),
    (1,  3, 500.00,  20),
    -- Show 2 (afternoon 2D) — Silver, Gold, Platinum
    (2,  1, 220.00,  70),
    (2,  2, 380.00,  45),
    (2,  3, 520.00,  18),
    -- Show 3 (evening 2D) — Silver, Gold, Platinum
    (3,  1, 250.00,  60),
    (3,  2, 400.00,  40),
    (3,  3, 560.00,  15),
    -- Show 4 (morning IMAX) — Silver, Gold, Recliner
    (4,  1, 350.00, 100),
    (4,  2, 550.00,  80),
    (4,  4, 900.00,  20),
    -- Show 5 (evening IMAX) — Silver, Gold, Recliner
    (5,  1, 400.00,  90),
    (5,  2, 600.00,  70),
    (5,  4, 950.00,  20),
    -- Show 6 (morning 3D) — Silver, Gold, Platinum
    (6,  1, 250.00,  60),
    (6,  2, 400.00,  40),
    (6,  3, 560.00,  20),
    -- Show 7 (afternoon 3D) — Silver, Gold, Platinum
    (7,  1, 270.00,  55),
    (7,  2, 420.00,  35),
    (7,  3, 580.00,  15),
    -- Show 8 (INOX morning 2D)
    (8,  1, 180.00,  70),
    (8,  2, 300.00,  40),
    -- Show 9 (INOX afternoon 2D)
    (9,  1, 200.00,  65),
    (9,  2, 330.00,  35),
    -- Show 10 (INOX 4DX morning)
    (10, 1, 450.00,  40),
    (10, 2, 600.00,  30),
    -- Show 11 (INOX 4DX evening)
    (11, 1, 500.00,  38),
    (11, 2, 650.00,  28);

-- -----------------------------------------------------------------------------
-- 7. Seat  (sample seats for Screen 1 at PVR Forum Mall — screen_id = 1)
-- -----------------------------------------------------------------------------
INSERT INTO Seat (screen_id, row_label, seat_number, category_id) VALUES
    -- Row A — Silver (category_id = 1)
    (1, 'A', 1, 1), (1, 'A', 2, 1), (1, 'A', 3, 1), (1, 'A', 4, 1), (1, 'A', 5, 1),
    -- Row B — Silver
    (1, 'B', 1, 1), (1, 'B', 2, 1), (1, 'B', 3, 1), (1, 'B', 4, 1), (1, 'B', 5, 1),
    -- Row C — Gold (category_id = 2)
    (1, 'C', 1, 2), (1, 'C', 2, 2), (1, 'C', 3, 2), (1, 'C', 4, 2), (1, 'C', 5, 2),
    -- Row D — Gold
    (1, 'D', 1, 2), (1, 'D', 2, 2), (1, 'D', 3, 2), (1, 'D', 4, 2), (1, 'D', 5, 2),
    -- Row E — Platinum (category_id = 3)
    (1, 'E', 1, 3), (1, 'E', 2, 3), (1, 'E', 3, 3), (1, 'E', 4, 3), (1, 'E', 5, 3);

-- -----------------------------------------------------------------------------
-- 8. User
-- -----------------------------------------------------------------------------
INSERT INTO `User` (full_name, email, phone) VALUES
    ('Aman Sharma',   'aman@example.com',   '9876543210'),
    ('Priya Mehta',   'priya@example.com',  '9123456789'),
    ('Rohan Kapoor',  'rohan@example.com',  '9988776655'),
    ('Sneha Reddy',   'sneha@example.com',  '9871234560'),
    ('Arjun Nair',    'arjun@example.com',  '9765432100');

-- -----------------------------------------------------------------------------
-- 9. Booking
-- -----------------------------------------------------------------------------
INSERT INTO Booking (user_id, show_id, total_amount, status, payment_ref) VALUES
    (1, 1,  700.00, 'CONFIRMED', 'PAY_BMS_20250110_0001'),  -- Aman, Show 1 (morning 2D)
    (2, 4, 1800.00, 'CONFIRMED', 'PAY_BMS_20250110_0002'),  -- Priya, Show 4 (IMAX)
    (3, 6,  800.00, 'CONFIRMED', 'PAY_BMS_20250110_0003'),  -- Rohan, Show 6 (3D)
    (4, 7,  840.00, 'CANCELLED', 'PAY_BMS_20250110_0004'),  -- Sneha, Show 7 (cancelled)
    (5, 5, 1900.00, 'CONFIRMED', 'PAY_BMS_20250110_0005');  -- Arjun, Show 5 (evening IMAX)

-- -----------------------------------------------------------------------------
-- 10. BookingSeat
-- -----------------------------------------------------------------------------
-- Booking 1: Aman booked 2 Gold seats for Show 1
INSERT INTO BookingSeat (booking_id, seat_id, price_paid) VALUES
    (1, 11, 350.00),   -- Row C, Seat 1 (Gold)
    (1, 12, 350.00);   -- Row C, Seat 2 (Gold)

-- Booking 2: Priya booked 2 Gold IMAX seats for Show 4
INSERT INTO BookingSeat (booking_id, seat_id, price_paid) VALUES
    (2, 13, 900.00),   -- Row C, Seat 3 (Gold/IMAX)
    (2, 14, 900.00);   -- Row C, Seat 4 (Gold/IMAX)

-- Booking 3: Rohan booked 2 Silver seats for Show 6
INSERT INTO BookingSeat (booking_id, seat_id, price_paid) VALUES
    (3, 1, 250.00),    -- Row A, Seat 1 (Silver)
    (3, 2, 300.00);    -- Row A, Seat 2 (Silver)

-- Booking 5: Arjun booked 2 Platinum seats for Show 5 (evening IMAX)
INSERT INTO BookingSeat (booking_id, seat_id, price_paid) VALUES
    (5, 21, 950.00),   -- Row E, Seat 1 (Platinum)
    (5, 22, 950.00);   -- Row E, Seat 2 (Platinum)
