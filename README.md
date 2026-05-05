# 🎬 BookMyShow — Database Design Assignment

A fully normalized relational database design for a movie ticketing platform (BookMyShow), covering entity modelling, SQL DDL, sample data, and query design.

---

## 📁 Repository Structure

```
bookmyshow-db-design/
├── schema.sql                  # CREATE TABLE statements (run this first)
├── sample_data.sql             # Sample INSERT statements
├── p2_query.sql                # P2 — Show listing query by theatre & date
└── BookMyShow_DB_Design.docx   # Full assignment document with explanations
```

---

## 🗂️ Entities

| Table | Description |
|---|---|
| `Theatre` | Cinema multiplex with location details |
| `Screen` | Auditorium inside a theatre (2D / 3D / IMAX / 4DX / DBOX) |
| `Movie` | Film metadata — title, language, genre, duration, certification |
| `SeatCategory` | Seat tiers — Silver, Gold, Platinum, Recliner |
| `Show` | A scheduled screening: Movie × Screen × Date × Time |
| `ShowSeatCategory` | Ticket price per seat tier per show |
| `Seat` | Individual physical seat in a screen |
| `User` | Registered customer |
| `Booking` | A ticket purchase by a user for a show |
| `BookingSeat` | Junction table — which seats belong to a booking |

---

## ▶️ How to Run

> Requires **MySQL 8.0+**

### Step 1 — Create the schema
```sql
source schema.sql;
```

### Step 2 — Load sample data
```sql
source sample_data.sql;
```

### Step 3 — Run the P2 query
Open `p2_query.sql`, set your preferred theatre and date at the top of the file, then run:
```sql
SET @theatre_id = 1;            -- 1 = PVR Cinemas Forum Mall
SET @show_date  = '2025-01-10';

source p2_query.sql;
```

---

## 🔍 P2 Query — Shows by Theatre & Date

Lists all scheduled shows at a given theatre on a given date, along with screen details, movie info, show timings, seat categories, and pricing.

```sql
SET @theatre_id = 1;
SET @show_date  = '2025-01-10';

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
JOIN   Screen              sc  ON  sc.theatre_id   = t.theatre_id
JOIN   `Show`              s   ON  s.screen_id     = sc.screen_id
JOIN   Movie               m   ON  m.movie_id      = s.movie_id
LEFT JOIN ShowSeatCategory ssc ON ssc.show_id      = s.show_id
LEFT JOIN SeatCategory     cat ON cat.category_id  = ssc.category_id
WHERE  t.theatre_id = @theatre_id
  AND  s.show_date  = @show_date
  AND  s.status     = 'SCHEDULED'
ORDER BY s.show_time, sc.screen_name, cat.category_id;
```

---

## ✅ Normalization

All tables comply with **1NF, 2NF, 3NF, and BCNF**.

| Normal Form | How it's satisfied |
|---|---|
| **1NF** | All columns are atomic. No arrays or comma-separated values. Every table has a surrogate integer primary key. |
| **2NF** | Single-column surrogate PKs eliminate partial dependencies. Composite keys (e.g. `ShowSeatCategory`) fully determine all non-key attributes. |
| **3NF** | No transitive dependencies. Show timings are not stored on `Booking`. Pricing is not stored on `Movie`. Each fact lives in exactly one place. |
| **BCNF** | Every determinant is a superkey. The natural candidate key on `Show` — `(screen_id, show_date, show_time)` — is enforced as a `UNIQUE` constraint. |

---

## 🔗 Key Relationships

```
Theatre   ──< Screen ──< Show >── Movie
                              |
                              ├──< ShowSeatCategory >── SeatCategory
                              └──< Booking >── User
                                       |
                                  BookingSeat >── Seat >── SeatCategory
```

---

## 📄 Full Documentation

See `BookMyShow_DB_Design.docx` for the complete write-up including:
- Entity attribute tables with data types and constraints
- Normalization walkthrough (1NF → BCNF) with examples
- Sample data tables
- P2 query with annotated explanation and expected output

## Submitted by: AMAN DUBEY

## Submitted by: AMAN DUBEY
