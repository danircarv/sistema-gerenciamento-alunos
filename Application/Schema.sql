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
CREATE TABLE students (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    registration_number TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);
CREATE TABLE courses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);
CREATE TABLE enrollments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    student_id UUID NOT NULL,
    course_id UUID NOT NULL,
    semester TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    UNIQUE(student_id, course_id, semester)
);
CREATE TABLE grades (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    enrollment_id UUID NOT NULL,
    description TEXT NOT NULL,
    value DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    weight DOUBLE PRECISION DEFAULT 1 NOT NULL
);
CREATE INDEX enrollments_student_id_index ON enrollments (student_id);
CREATE INDEX enrollments_course_id_index ON enrollments (course_id);
CREATE INDEX grades_enrollment_id_index ON grades (enrollment_id);
ALTER TABLE enrollments ADD CONSTRAINT enrollments_ref_student_id FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE;
ALTER TABLE enrollments ADD CONSTRAINT enrollments_ref_course_id FOREIGN KEY (course_id) REFERENCES courses (id) ON DELETE CASCADE;
ALTER TABLE grades ADD CONSTRAINT grades_ref_enrollment_id FOREIGN KEY (enrollment_id) REFERENCES enrollments (id) ON DELETE CASCADE;
ALTER TABLE students ADD CONSTRAINT students_name_not_blank CHECK (btrim(name) <> '');
ALTER TABLE students ADD CONSTRAINT students_email_format CHECK (regexp_like(email, '^[^@[:space:]]+@[^@[:space:]]+[.][^@[:space:]]+$'));
ALTER TABLE students ADD CONSTRAINT students_registration_number_format CHECK (regexp_like(registration_number, '^[0-9]{7}$'));
ALTER TABLE courses ADD CONSTRAINT courses_name_not_blank CHECK (btrim(name) <> '');
ALTER TABLE courses ADD CONSTRAINT courses_code_not_blank CHECK (btrim(code) <> '');
ALTER TABLE enrollments ADD CONSTRAINT enrollments_semester_format CHECK (regexp_like(semester, '^[0-9]{4}[.][12]$'));
ALTER TABLE grades ADD CONSTRAINT grades_description_not_blank CHECK (btrim(description) <> '');
ALTER TABLE grades ADD CONSTRAINT grades_value_range CHECK ((value >= 0) AND (value <= 10));
ALTER TABLE grades ADD CONSTRAINT grades_weight_range CHECK ((weight > 0) AND (weight <= 10));
