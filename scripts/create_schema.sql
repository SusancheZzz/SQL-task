create table if not exists student
(
    id           SERIAL,
    spec_id      SERIAL,
    name         VARCHAR(50),
    surname      VARCHAR(50),
    birthdate    TIMESTAMP,
    create_date  TIMESTAMP,
    update_date  TIMESTAMP,
    phone_number VARCHAR(20)
);

create table if not exists specializations
(
    id        SERIAL,
    spec_code VARCHAR(20),
    name_spec VARCHAR(255)
);

create table if not exists teachers
(
    id      SERIAL,
    name    VARCHAR(50),
    surname VARCHAR(50)
);

create table if not exists lessons
(
    id          SERIAL,
    name_lesson VARCHAR(255)
);

create table if not exists exams
(
    id        SERIAL,
    lesson_id SERIAL,
    date      TIMESTAMP
);

create table if not exists exams_result
(
    id         SERIAL,
    student_id SERIAL,
    exam_id    SERIAL,
    grade      INT
);

create table if not exists specialization_lesson
(
    id      SERIAL,
    spec_id SERIAL,
    less_id SERIAL
);

create table if not exists teacher_lesson
(
    id         SERIAL,
    teacher_id SERIAL,
    less_id    SERIAL
);

create table snapshot
(
    id              SERIAL,
    student_name    VARCHAR(50),
    student_surname VARCHAR(50),
    subject_name    VARCHAR(255),
    mark            INT,
    snapshot_date   TIMESTAMP
);



