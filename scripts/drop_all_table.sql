drop table if exists student cascade;
drop table if exists specializations cascade;
drop table if exists lessons cascade;
drop table if exists exams cascade;
drop table if exists exams_result cascade;
drop table if exists spec_less cascade;
drop table if exists teacher_less cascade;
drop table if exists teachers cascade;
drop table if exists snapshot;

drop function get_students_in_red_zone();
drop function get_avg_grade_for_lesson(id_lesson integer);
drop function get_student_avg_grade(id_student integer);
drop function audit_update_student();
drop procedure create_snapshot(snapshot_time timestamp);