
INSERT INTO specializations (spec_code, name_spec)
SELECT 'SPEC-' || generate_series, 'Специальность ' || generate_series
FROM generate_series(1, 20);

INSERT INTO teachers (name, surname)
SELECT names[floor(random() * array_length(names, 1)) + 1],
       surnames[floor(random() * array_length(surnames, 1)) + 1]
FROM generate_series(1, 500)
         JOIN LATERAL (
    SELECT ARRAY ['Alice', 'Bob', 'Charlie', 'David', 'Emma', 'Frank', 'Grace', 'Hannah']       AS names,
           ARRAY ['J-Smith', 'Jonson', 'Williams', 'O`Brown', 'Jones', 'Garcia', 'Miller', 'Davis'] AS surnames
    ) AS name_data ON true;

INSERT INTO lessons (name_lesson)
SELECT 'Lesson ' || generate_series
FROM generate_series(1, 1000);

INSERT INTO student (spec_id, name, surname, birthdate, phone_number)
SELECT floor(random() * 20 + 1),
       names[floor(random() * array_length(names, 1)) + 1],
       surnames[floor(random() * array_length(surnames, 1)) + 1],
       now() - interval '15 years' - (random() * interval '10 years'), -- возраст 15-25 лет
       '+7(' || lpad((floor(random() * 900) + 100)::text, 3, '0') || ')-' ||
       lpad((floor(random() * 900) + 100)::text, 3, '0') || '-' ||
       lpad((floor(random() * 9000) + 1000)::text, 4, '0')
FROM generate_series(1, 100000)
         JOIN LATERAL (
    SELECT ARRAY ['Alice', 'Bob', 'Charlie', 'David', 'Emma', 'Frank', 'Grace', 'Hannah']       AS names,
           ARRAY ['J-Smith', 'Jonson', 'Williams', 'O`Brown', 'Jones', 'Garcia', 'Miller', 'Davis'] AS surnames
    ) AS name_data ON true;

INSERT INTO exams (lesson_id, date)
SELECT floor(random() * 1000 + 1),
       now() - interval '6 month' * random()
FROM generate_series(1, 10000);

INSERT INTO exams_result (student_id, exam_id, grade)
SELECT floor(random() * 100000 + 1),
       floor(random() * 10000 + 1),
       floor(random() * 4 + 2)
FROM generate_series(1, 1000000);

INSERT INTO specialization_lesson (spec_id, less_id)
SELECT floor(random() * 20 + 1),
       floor(random() * 1000 + 1)
FROM generate_series(1, 2000);

INSERT INTO teacher_lesson (teacher_id, less_id)
SELECT floor(random() * 500 + 1),
       floor(random() * 1000 + 1)
FROM generate_series(1, 1000);

