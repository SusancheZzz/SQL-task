--1. Найти пользователя по имени (точное совпадение)
select st.id, sp.name_spec, st.name, st.surname, st.birthdate, st.create_date, st.phone_number
from student st
         join specializations sp on st.spec_id = sp.id
where st.name ilike 'bob'
order by st.id;

--2. Найти пользователя по фамилии (частичное совпадение)
select st.id, sp.name_spec, st.name, st.surname, st.birthdate, st.create_date, st.phone_number
from student st
         join specializations sp on st.spec_id = sp.id
where st.surname ilike '%mit%'
order by st.id;

--3. Найти пользователя по телефонному номеру (частичное совпадение)
select st.id, st.phone_number, sp.name_spec, st.name, st.surname, st.birthdate, st.create_date
from student st
         join specializations sp on st.spec_id = sp.id
where st.phone_number like '%-113-%'
order by st.id;

--4. Найти пользователя с его оценками по фамилии (частичное совпадение)
select st.id, st.name, st.surname, les.name_lesson, ex.date, er.grade
from student st
         join exams_result er on st.id = er.student_id
         join exams ex on er.exam_id = ex.id
         join lessons les on ex.lesson_id = les.id
where st.surname ilike '%mit%'
order by er.grade desc;

--7. Snapshot текущего состояния таблицы
call create_snapshot(now()::timestamp);

--8. Средняя оценка для заданного студента
select get_student_avg_grade(234);

--9. Средняя оценка по предмету
select get_avg_grade_for_lesson(10);

--10. Поиск студентов в красной зоне
select *
from get_students_in_red_zone()
order by low_grades_count desc;


--11. Индексы

--B-Tree idx
explain analyze
select *
from exams_result
where grade = 5;
create index idx_grade_hash on exams_result (grade);

--HASH idx
explain analyze
select *
from student
where name = 'Charlie';
create index idx_student_name_btree on student using hash (name);

--GIN idx
explain analyze
select *
from lessons
where name_lesson like '%3%';
create extension if not exists pg_trgm;
create index idx_lesson_name_gin on lessons using gin (name_lesson gin_trgm_ops);

--GiST idx
explain analyze
select *
from exams
where tsrange(date::timestamp without time zone, date::timestamp without time zone, '[]')
          && tsrange(now()::timestamp without time zone - interval '6 months', now()::timestamp without time zone, '[]');
create index idx_exam_date_gist on exams using gist (tsrange(date::timestamp without time zone,
                                                             date::timestamp without time zone, '[]'));

--Размеры всех индексов (кастомные -- 'idx_...')
select relname as index_name, pg_size_pretty(pg_relation_size(oid)) AS index_size
from pg_class
where relkind = 'i';
