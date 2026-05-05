-- =============================================================================
-- BookMyShow Database Design Assignment
-- File        : schema.sql
-- Description : CREATE TABLE statements for all entities
-- Database    : MySQL 8.0+
-- Normal Forms: 1NF, 2NF, 3NF, BCNF
-- Run Order   : Execute this file first, before sample_data.sql
-- =============================================================================

-- Drop tables in reverse dependency order (safe re-run)
DROP TABLE IF EXISTS BookingSeat;
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Seat;
DROP TABLE IF EXISTS ShowSeatCategory;
DROP TABLE IF EXISTS `Show`;
DROP TABLE IF EXISTS SeatCategory;
DROP TABLE IF EXISTS Movie;
DROP TABLE IF EXISTS Screen;
DROP TABLE IF EXISTS `User`;
DROP TABLE IF EXISTS Theatre;

-- -----------------------------------------------------------------------------
-- 1. Theatre
--    A cinema multiplex with physical location details.
--    One Theatre → many Screens.
-- -----------------------------------------------------------------------------
CREATE TABLE Theatre (
    theatre_id   INT          NOT NULL AUTO_INCREMENT,
    name         VARCHAR(150) NOT NULL,
    address      VARCHAR(255) NOT NULL,
    city         VARCHAR(100) NOT NULL,
    state        VARCHAR(100) NOT NULL,
    pincode      CHAR(6)      NOT NULL,
    phone        VARCHAR(15),
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (theatre_id)
);

-- -----------------------------------------------------------------------------
-- 2. Screen
--    A physical auditorium inside a Theatre.
--    One Screen → many Shows (over different dates/times).
-- -----------------------------------------------------------------------------
CREATE TABLE Screen (
    screen_id    INT         NOT NULL AUTO_INCREMENT,
    theatre_id   INT         NOT NULL,
    screen_name  VARCHAR(50) NOT NULL,
    screen_type  ENUM('2D','3D','IMAX','4DX','DBOX') NOT NULL,
    total_seats  SMALLINT    NOT NULL,
    PRIMARY KEY (screen_id),
    CONSTRAINT fk_screen_theatre
        FOREIGN KEY (theatre_id) REFERENCES Theatre(theatre_id)
        ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 3. Movie
--    Film metadata. A Movie can run across many Shows at different theatres.
-- -----------------------------------------------------------------------------
CREATE TABLE Movie (
    movie_id      INT          NOT NULL AUTO_INCREMENT,
    title         VARCHAR(200) NOT NULL,
    language      VARCHAR(50)  NOT NULL,
    genre         VARCHAR(100) NOT NULL,
    duration_min  SMALLINT     NOT NULL,
    certification ENUM('U','UA','A','S') NOT NULL,
    release_date  DATE         NOT NULL,
    description   TEXT,
    PRIMARY KEY (movie_id)
);

-- -----------------------------------------------------------------------------
-- 4. SeatCategory
--    Defines seat tiers (Silver, Gold, Platinum, Recliner).
--    Pricing per tier per Show is stored in ShowSeatCategory — NOT here —
--    so different shows can have different prices for the same tier.
-- -----------------------------------------------------------------------------
CREATE TABLE SeatCategory (
    category_id   INT         NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    description   VARCHAR(200),
    PRIMARY KEY (category_id),
    UNIQUE KEY uq_category_name (category_name)
);

-- -----------------------------------------------------------------------------
-- 5. Show
--    The central scheduling entity: Movie × Screen × Date × Time.
--    UNIQUE constraint on (screen_id, show_date, show_time) prevents a screen
--    from being double-booked at the same slot.
--    NOTE: `Show` is a reserved word in MySQL, so it is backtick-quoted.
-- -----------------------------------------------------------------------------
CREATE TABLE `Show` (
    show_id    INT  NOT NULL AUTO_INCREMENT,
    movie_id   INT  NOT NULL,
    screen_id  INT  NOT NULL,
    show_date  DATE NOT NULL,
    show_time  TIME NOT NULL,
    status     ENUM('SCHEDULED','CANCELLED','COMPLETED')
               NOT NULL DEFAULT 'SCHEDULED',
    PRIMARY KEY (show_id),
    -- Natural candidate key: no two shows can share the same screen + slot
    UNIQUE KEY uq_screen_slot (screen_id, show_date, show_time),
    CONSTRAINT fk_show_movie
        FOREIGN KEY (movie_id)  REFERENCES Movie(movie_id),
    CONSTRAINT fk_show_screen
        FOREIGN KEY (screen_id) REFERENCES Screen(screen_id)
);

-- -----------------------------------------------------------------------------
-- 6. ShowSeatCategory
--    Resolves the many-to-many between Show and SeatCategory.
--    Stores the ticket price and remaining available seats per tier per show.
--    This allows matinee vs evening shows to have different prices for the
--    same seat tier (no transitive dependency — satisfies 3NF/BCNF).
-- -----------------------------------------------------------------------------
CREATE TABLE ShowSeatCategory (
    show_seat_cat_id INT           NOT NULL AUTO_INCREMENT,
    show_id          INT           NOT NULL,
    category_id      INT           NOT NULL,
    price            DECIMAL(8,2)  NOT NULL,
    available_seats  SMALLINT      NOT NULL,
    PRIMARY KEY (show_seat_cat_id),
    -- A show can only have one price entry per seat tier
    UNIQUE KEY uq_show_category (show_id, category_id),
    CONSTRAINT fk_ssc_show
        FOREIGN KEY (show_id)     REFERENCES `Show`(show_id),
    CONSTRAINT fk_ssc_category
        FOREIGN KEY (category_id) REFERENCES SeatCategory(category_id)
);

-- -----------------------------------------------------------------------------
-- 7. Seat
--    Represents an individual physical seat in a Screen.
--    (screen_id, row_label, seat_number) is unique — no two seats share
--    the same position in the same screen.
-- -----------------------------------------------------------------------------
CREATE TABLE Seat (
    seat_id     INT      NOT NULL AUTO_INCREMENT,
    screen_id   INT      NOT NULL,
    row_label   CHAR(2)  NOT NULL,
    seat_number SMALLINT NOT NULL,
    category_id INT      NOT NULL,
    PRIMARY KEY (seat_id),
    UNIQUE KEY uq_seat_position (screen_id, row_label, seat_number),
    CONSTRAINT fk_seat_screen
        FOREIGN KEY (screen_id)   REFERENCES Screen(screen_id),
    CONSTRAINT fk_seat_category
        FOREIGN KEY (category_id) REFERENCES SeatCategory(category_id)
);

-- -----------------------------------------------------------------------------
-- 8. User
--    A registered customer on the platform.
--    NOTE: `User` is a reserved word in MySQL, so it is backtick-quoted.
-- -----------------------------------------------------------------------------
CREATE TABLE `User` (
    user_id    INT          NOT NULL AUTO_INCREMENT,
    full_name  VARCHAR(150) NOT NULL,
    email      VARCHAR(150) NOT NULL,
    phone      VARCHAR(15)  NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    UNIQUE KEY uq_user_email (email),
    UNIQUE KEY uq_user_phone (phone)
);

-- -----------------------------------------------------------------------------
-- 9. Booking
--    Records a ticket purchase by a User for a Show.
--    Individual seat assignments are in BookingSeat.
--    total_amount is stored for audit/receipt purposes (snapshot at time
--    of booking — satisfies 3NF since it doesn't derive from live price data).
-- -----------------------------------------------------------------------------
CREATE TABLE Booking (
    booking_id   INT           NOT NULL AUTO_INCREMENT,
    user_id      INT           NOT NULL,
    show_id      INT           NOT NULL,
    booked_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status       ENUM('CONFIRMED','CANCELLED','PENDING')
                 NOT NULL DEFAULT 'CONFIRMED',
    payment_ref  VARCHAR(100),
    PRIMARY KEY (booking_id),
    UNIQUE KEY uq_payment_ref (payment_ref),
    CONSTRAINT fk_booking_user
        FOREIGN KEY (user_id) REFERENCES `User`(user_id),
    CONSTRAINT fk_booking_show
        FOREIGN KEY (show_id) REFERENCES `Show`(show_id)
);

-- -----------------------------------------------------------------------------
-- 10. BookingSeat
--     Junction table: resolves the many-to-many between Booking and Seat.
--     price_paid captures the price at booking time (snapshot pricing) so
--     future price changes on ShowSeatCategory don't affect past receipts.
--     UNIQUE on (booking_id, seat_id) ensures a seat isn't added twice to
--     the same booking.
-- -----------------------------------------------------------------------------
CREATE TABLE BookingSeat (
    booking_seat_id INT          NOT NULL AUTO_INCREMENT,
    booking_id      INT          NOT NULL,
    seat_id         INT          NOT NULL,
    price_paid      DECIMAL(8,2) NOT NULL,
    PRIMARY KEY (booking_seat_id),
    UNIQUE KEY uq_booking_seat (booking_id, seat_id),
    CONSTRAINT fk_bs_booking
        FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    CONSTRAINT fk_bs_seat
        FOREIGN KEY (seat_id)    REFERENCES Seat(seat_id)
);
