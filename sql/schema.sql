CREATE DATABASE dharma;

CREATE OR REPLACE FUNCTION is_valid_abn(abn TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    sum INTEGER := 0;
    weight INTEGER[] := ARRAY[10, 1, 3, 5, 7, 9, 11];
    clean_abn TEXT := REGEXP_REPLACE(abn, '[^\d]+', '', 'g');
BEGIN
    IF LENGTH(clean_abn) != 11 THEN
        RETURN FALSE;
    END IF;

    FOR i IN 1..7 LOOP
        sum := sum + (CAST(SUBSTRING(clean_abn, i, 1) AS INTEGER) - (i = 1)::INTEGER) * weight[i];
    END LOOP;

    FOR i IN 8..11 LOOP
        sum := sum + CAST(SUBSTRING(clean_abn, i, 1) AS INTEGER) * (i - 1);
    END LOOP;

    RETURN sum % 89 = 0;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE fund (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    USI TEXT NOT NULL,
    ABN TEXT NOT NULL,
    phone TEXT NOT NULL,
    CONSTRAINT abn_validation CHECK (is_valid_abn(ABN))
);

CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    firstName TEXT NOT NULL,
    secondName TEXT NOT NULL,
    dateOfBirth DATE NOT NULL,
    memberNumber TEXT NOT NULL,
    dateJoined DATE NOT NULL,
    taxFileNumber TEXT NOT NULL
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    member_id INTEGER UNIQUE NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE CASCADE
);

CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    member_id INTEGER NOT NULL,
    street_address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    postal_code TEXT NOT NULL,
    country TEXT NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE CASCADE
);

CREATE TABLE beneficiaries (
    id SERIAL PRIMARY KEY,
    member_id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    relationship TEXT NOT NULL,
    percent_share DECIMAL(5, 2) NOT NULL CHECK (percent_share >= 0 AND percent_share <= 100),
    FOREIGN KEY (member_id) REFERENCES members (id) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION check_percent_sum()
RETURNS TRIGGER AS $$
DECLARE
    total_percent DECIMAL;
BEGIN
    SELECT SUM(percent_share)
    INTO total_percent
    FROM beneficiaries
    WHERE member_id = NEW.member_id;

    IF (total_percent + NEW.percent_share) > 100 THEN
        RAISE EXCEPTION 'The total percentage share for beneficiaries linked to a single member cannot exceed 100';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_percent_sum_trigger
BEFORE INSERT OR UPDATE ON beneficiaries
FOR EACH ROW
EXECUTE FUNCTION check_percent_sum();
