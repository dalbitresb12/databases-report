-- Initialize

use coursera_db;
go

begin transaction;
go

-- 1. Hallar el promedio de ratings de instructores agrupado por institución (función)

create or alter function dbo.InstructorRatingAvgByInstitution()
    returns table as
        return
            (
                select Ic.institution_id, AVG(It.rating) as "rating_average"
                from Instructor It
                         join Institution Ic on Ic.institution_id = It.institution_id
                group by Ic.institution_id
            );
go

select *
from dbo.InstructorRatingAvgByInstitution();
go

-- 2. Actualizar el campo Instructor.is_top_instructor dependiendo del rating de
-- cada instructor. Este campo dependerá de si el rating del instructor es mayor
-- al promedio de ratings de instructores de una misma institución, al promedio de
-- ratings global (todas las instituciones) y mayor a 0.7 (el que sea mayor) (procedimiento)

create or alter procedure dbo.UpdateTopInstructors as
declare @global_average real;

select @global_average = AVG(I.rating)
from Instructor I;

update It
set It.is_top_instructor =
        IIF(It.rating >= (select MAX(i) from (values (It.rating), (@global_average), (0.7)) as T(i)),
            1, 0)
from Instructor It
         join Institution Ic on Ic.institution_id = It.institution_id
         join dbo.InstructorRatingAvgByInstitution() Av on It.institution_id = Av.institution_id;
go

exec dbo.UpdateTopInstructors;

select I.rating, I.is_top_instructor, Av.rating_average
from Instructor I
         join dbo.InstructorRatingAvgByInstitution() Av on I.institution_id = Av.institution_id;
go

-- 3. Crear un trigger que cada vez que se actualicen los ratings de los instructores,
-- se ejecute el procedimiento de actualización de top instructors (trigger)

create or alter trigger dbo.UpdateTopInstructorsOnUpdate
    on Instructor
    after update as
    exec dbo.UpdateTopInstructors;
go

exec dbo.UpdateTopInstructors;
go

select I.instructor_id, I.rating, I.is_top_instructor
from Instructor I
where I.instructor_id in (1, 2);
go

update Instructor
set rating = 0.69
where instructor_id = 1;

update Instructor
set rating = 0.83
where instructor_id = 2;
go

select I.instructor_id, I.rating, I.is_top_instructor
from Instructor I
where I.instructor_id in (1, 2);
go

-- 4. Mostrar los nombres, correos electrónicos y promedios de los estudiantes con
-- certificados que superen la nota promedio para cierto curso en
-- cierto periodo de tiempo (función con subquery)

create or alter function dbo.TopStudentsOfClass(
    @course_id int,
    @start_date datetime,
    @end_date datetime
)
    returns table as
        return
            (
                select S.fullname, S.email, C.grade_achieved
                from Student S
                         join Membership M on S.student_id = M.student_id
                         join Certificate C on C.certificate_id = M.certificate_code
                where M.course_id = @course_id
                  and C.date_achieved between @start_date and @end_date
                  and M.finished_course = 1
                  and C.grade_achieved >= (
                    select AVG(C.grade_achieved)
                    from Certificate C
                             join Membership M on C.certificate_id = M.certificate_code
                    where C.date_achieved between @start_date and @end_date
                      and M.course_id = @course_id
                      and M.finished_course = 1
                )
            );
go

select *
from dbo.TopStudentsOfClass(1, '2014-01-01', '2021-01-01');
go

-- Cleanup

drop function dbo.TopStudentsOfClass;
drop trigger dbo.UpdateTopInstructorsOnUpdate;
drop procedure dbo.UpdateTopInstructors;
drop function dbo.InstructorRatingAvgByInstitution;
go

rollback;
