alter table if exists specializations
    add primary key (id),
    alter column spec_code set not null,
    add unique (spec_code),
    alter column name_spec set not null,
    add unique (name_spec);

alter table if exists lessons
    add primary key (id),
    add unique (name_lesson),
    alter column name_lesson set not null;

alter table if exists teachers
    add primary key (id),
    add check (name ~ '^[A-Za-z`\-]+$'),
    alter column name set not null,
    add check (surname ~ '^[A-Za-z`-]+$'),
    alter column surname set not null;

alter table if exists student
    add primary key (id),
    add foreign key (spec_id) references specializations (id),
    add check (name ~ '^[A-Za-z`\-]+$'),
    alter column name set not null,
    add check (surname ~ '^[A-Za-z`\-]+$'),
    alter column surname set not null,
    add check (birthdate <= now() - interval '15 years'), -- возраст от 15 лет
    alter column create_date set default now(),
    alter column update_date set default now(),
    add check (phone_number ~ '^\+7\([0-9]{3}\)-[0-9]{3}-[0-9]{4}$');

alter table if exists exams
    add primary key (id),
    add foreign key (lesson_id) references lessons (id),
    alter column date set not null,
    add check (date <= now());

alter table if exists exams_result
    add primary key (id),
    add foreign key (student_id) references student (id),
    add foreign key (exam_id) references exams (id),
    add check (grade between 2 and 5),
    alter column grade set not null;

alter table if exists spec_less
    add primary key (id),
    add foreign key (spec_id) references specializations (id),
    add foreign key (less_id) references lessons (id);

alter table if exists teacher_less
    add primary key (id),
    add foreign key (teacher_id) references teachers (id),
    add foreign key (less_id) references lessons (id);

alter table if exists snapshot
    add primary key (id),
    alter column student_name set not null,
    alter column student_surname set not null,
    alter column subject_name set not null,
    alter column mark set not null,
    add check (mark between 2 and 5),
    alter column snapshot_date set default now();


create or replace function audit_update_student()
    returns trigger
    language plpgsql
as
$$
begin
    if tg_table_name = 'exams_result' then
        update student
        set update_date = now()
        where id = new.student_id;
        return new;

    elseif tg_table_name = 'student' then
        new.update_date := now();
        return new;

    end if;

    return null;
end;
$$;


create trigger student_update_trigger
    before update
    on student
    for each row
execute function audit_update_student();


create trigger exam_result_update_student_trigger
    before update or insert or delete
    on exams_result
    for each row
execute function audit_update_student();


create or replace procedure create_snapshot(snapshot_time TIMESTAMP)
    language plpgsql
as
$$
begin
    insert into snapshot (student_name, student_surname, subject_name, mark, snapshot_date)
    select st.name,
           st.surname,
           l.name_lesson,
           er.grade,
           snapshot_date

    from exams_result er
             join student st on st.id = er.student_id
             join exams e on e.id = er.exam_id
             join lessons l on l.id = e.lesson_id;

    raise notice 'Snapshot created at %', snapshot_time;
end;
$$;


create or replace function get_student_avg_grade(id_student INT)
    returns numeric
    language plpgsql
as
$$
declare
    avg_grade numeric;
begin
    select round(avg(grade), 2)
    into avg_grade
    from exams_result er
    where er.student_id = id_student;

    return COALESCE(avg_grade, 0); --0, если еще нет оценок
end;
$$;


create or replace function get_avg_grade_for_lesson(id_lesson INT)
    returns numeric
    language plpgsql
as
$$
declare
    avg_grade numeric;
begin
    select round(avg(grade), 2)
    into avg_grade
    from exams_result er
             join exams ex on er.exam_id = ex.id
             join lessons les on ex.lesson_id = les.id
    where les.id = id_lesson;

    return COALESCE(avg_grade, 0); --0, если еще нет оценок
end;
$$;


create or replace function get_students_in_red_zone()
    returns table
            (
                id_student       INT,
                name             VARCHAR,
                surname          VARCHAR,
                low_grades_count BIGINT
            )
    language plpgsql
as
$$
begin
    return query
        select s.id            as id_student,
               s.name,
               s.surname,
               COUNT(er.grade) as low_grades_count
        from student s
                 join exams_result er on s.id = er.student_id
        where er.grade = 2
        group by s.id, s.name, s.surname
        having COUNT(er.grade) > 1;
end;
$$;

create index if not exists idx_exams_result_grade on exams_result(grade);
create index if not exists idx_lessons_name on lessons(name_lesson);
create index if not exists idx_students_surname on student(surname);
create index if not exists idx_teachers_surname on teachers(surname);
