-- =============================================================================
-- BookMyShow Database Design Assignment
-- File        : p2_query.sql
-- Description : P2 — List all shows on a given date at a given theatre,
--               with their respective show timings and seat category pricing.
-- Database    : MySQL 8.0+
-- Pre-requisite: Run schema.sql and sample_data.sql first
-- =============================================================================

-- -----------------------------------------------------------------------------
-- USAGE
-- Replace the two SET values below to query any theatre + date combination.
--   @theatre_id : theatre_id from the Theatre table
--   @show_date  : date in 'YYYY-MM-DD' format
-- -----------------------------------------------------------------------------

SET @theatre_id = 1;               -- e.g. 1 = PVR Cinemas Forum Mall
SET @show_date  = '2025-01-10';    -- e.g. any of the next 7 dates on BookMyShow

-- -----------------------------------------------------------------------------
-- P2 Query
-- Logic:
--   1. Start from Theatre, filter by @theatre_id
--   2. JOIN Screen     → get all screens in that theatre
--   3. JOIN Show       → get all shows on @show_date on those screens
--   4. JOIN Movie      → get movie metadata (title, language, duration, cert)
--   5. LEFT JOIN ShowSeatCategory → fan out to all seat pricing tiers per show
--   6. LEFT JOIN SeatCategory     → get the human-readable tier name
--   LEFT JOIN (vs INNER JOIN) on pricing ensures shows with no pricing rows
--   still appear in results rather than being silently dropped.
-- -----------------------------------------------------------------------------
SELECT
    t.name                      AS theatre_name,
    sc.screen_name,
    sc.screen_type,
    m.title                     AS movie_title,
    m.language,
    m.certification,
    m.duration_min              AS duration_minutes,
    s.show_date,
    s.show_time,
    s.status                    AS show_status,
    cat.category_name           AS seat_category,
    ssc.price                   AS ticket_price,
    ssc.available_seats
FROM   Theatre t
JOIN   Screen             sc  ON  sc.theatre_id   = t.theatre_id
JOIN   `Show`             s   ON  s.screen_id     = sc.screen_id
JOIN   Movie              m   ON  m.movie_id      = s.movie_id
LEFT JOIN ShowSeatCategory ssc ON ssc.show_id     = s.show_id
LEFT JOIN SeatCategory    cat  ON cat.category_id = ssc.category_id
WHERE  t.theatre_id = @theatre_id
  AND  s.show_date  = @show_date
  AND  s.status     = 'SCHEDULED'
ORDER BY
    s.show_time,          -- chronological order within the day
    sc.screen_name,       -- group by screen
    cat.category_id;      -- Silver → Gold → Platinum → Recliner

-- =============================================================================
-- EXPECTED OUTPUT (theatre_id = 1, show_date = '2025-01-10')
-- =============================================================================
-- theatre_name              | screen_name | screen_type | movie_title    | language | certification | duration_minutes | show_date  | show_time | show_status | seat_category | ticket_price | available_seats
-- PVR Cinemas Forum Mall    | Screen 1    | 2D          | Kalki 2898 AD  | Telugu   | UA            | 181              | 2025-01-10 | 09:30:00  | SCHEDULED   | Silver        | 200.00       | 80
-- PVR Cinemas Forum Mall    | Screen 1    | 2D          | Kalki 2898 AD  | Telugu   | UA            | 181              | 2025-01-10 | 09:30:00  | SCHEDULED   | Gold          | 350.00       | 50
-- PVR Cinemas Forum Mall    | Screen 1    | 2D          | Kalki 2898 AD  | Telugu   | UA            | 181              | 2025-01-10 | 09:30:00  | SCHEDULED   | Platinum      | 500.00       | 20
-- PVR Cinemas Forum Mall    | Screen 2    | 3D          | Stree 2        | Hindi    | UA            | 135              | 2025-01-10 | 10:00:00  | SCHEDULED   | Silver        | 250.00       | 60
-- PVR Cinemas Forum Mall    | Screen 2    | 3D          | Stree 2        | Hindi    | UA            | 135              | 2025-01-10 | 10:00:00  | SCHEDULED   | Gold          | 400.00       | 40
-- PVR Cinemas Forum Mall    | Screen 2    | 3D          | Stree 2        | Hindi    | UA            | 135              | 2025-01-10 | 10:00:00  | SCHEDULED   | Platinum      | 560.00       | 20
-- PVR Cinemas Forum Mall    | IMAX Hall   | IMAX        | Kalki 2898 AD  | Telugu   | UA            | 181              | 2025-01-10 | 11:00:00  | SCHEDULED   | Silver        | 350.00       | 100
-- PVR Cinemas Forum Mall    | IMAX Hall   | IMAX        | Kalki 2898 AD  | Telugu   | UA            | 181              | 2025-01-10 | 11:00:00  | SCHEDULED   | Gold          | 550.00       | 80
-- PVR Cinemas Forum Mall    | IMAX Hall   | IMAX        | Kalki 2898 AD  | Telugu   | UA            | 181              | 2025-01-10 | 11:00:00  | SCHEDULED   | Recliner      | 900.00       | 20
-- ... and so on for afternoon and evening shows
-- =============================================================================
