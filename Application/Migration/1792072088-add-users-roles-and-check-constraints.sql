CREATE TYPE user_role AS ENUM ('admin', 'professor');
CREATE TABLE users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    locked_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    failed_login_attempts INT DEFAULT 0 NOT NULL,
    role user_role DEFAULT 'professor' NOT NULL
);
ALTER TABLE students ADD CONSTRAINT students_name_not_blank CHECK (btrim(name) <> '');
ALTER TABLE students ADD CONSTRAINT students_email_format CHECK (regexp_like(email, '^[^@[:space:]]+@[^@[:space:]]+[.][^@[:space:]]+$'));
ALTER TABLE students ADD CONSTRAINT students_registration_number_format CHECK (regexp_like(registration_number, '^[0-9]{7}$'));
ALTER TABLE courses ADD CONSTRAINT courses_name_not_blank CHECK (btrim(name) <> '');
ALTER TABLE courses ADD CONSTRAINT courses_code_not_blank CHECK (btrim(code) <> '');
ALTER TABLE enrollments ADD CONSTRAINT enrollments_semester_format CHECK (regexp_like(semester, '^[0-9]{4}[.][12]$'));
ALTER TABLE grades ADD CONSTRAINT grades_description_not_blank CHECK (btrim(description) <> '');
ALTER TABLE grades ADD CONSTRAINT grades_value_range CHECK ((value >= 0) AND (value <= 10));
ALTER TABLE grades ADD CONSTRAINT grades_weight_range CHECK ((weight > 0) AND (weight <= 10));
