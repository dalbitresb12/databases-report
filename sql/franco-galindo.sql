-- Initialize

use coursera_db;
go

begin transaction;
go

-- 1. Mostrar la cantidad de alumnos inscritos y el porcentaje de aprobados en cierto curso durante todos los años (Función).

--Crear función para obtener porcentaje de aprobados en cierto año y curso
CREATE FUNCTION P_ALUMNOS_APROBADOS(@year INT, @course_id INT, @q_students INT) RETURNS FLOAT
AS
BEGIN
DECLARE @p_students INT
SELECT @p_students = (100 * COUNT(M.student_id)/@q_students)
From Membership M INNER JOIN Course C ON M.course_id = C.course_id
Where YEAR(M.enrollment_date) = @year AND C.course_id = @course_id AND M.finished_course = 1;
RETURN @p_students
END;
go

--Crear función para obtener la tabla entera
CREATE FUNCTION COURSE_APPROVED_EVOLUTION(@course_id int) RETURNS TABLE
AS
RETURN (Select COUNT(M.student_id) as "Q_enrolled_students",
dbo.P_ALUMNOS_APROBADOS(YEAR(M.enrollment_date), @course_id, COUNT(M.student_id)) as "Approved_porcentage",
YEAR(M.enrollment_date) as "Enrollment_year"
FROM Membership M
WHERE M.course_id = @course_id
GROUP BY M.course_id, YEAR(M.enrollment_date));
go

--Ingresar la id del curso deseado para obtener la cantidad de inscritos y su porcentaje de aprobados a lo largo de los años
DECLARE @selected_course INT = 2
Select CE.Q_enrolled_students, CE.Approved_porcentage, CE.Enrollment_year
From COURSE_APPROVED_EVOLUTION(@selected_course) CE
Order by 3 asc;
go


--2. Mostrar el promedio de edad de un curso junto a su cantidad de alumnos inscritos entre un rango de edad ingresado, 
-- mostrando adicionalmente, su promedio. (Función con subquery)

CREATE FUNCTION EDAD_ALUMNOS_CURSO(@course_id int, @edadInicio int, @edadFinal int) RETURNS TABLE
AS
RETURN(SELECT M.course_id,
ISNULL(AR.q_students_in_range, 0) as "q_students_in_range",
AVG(DATEDIFF(YEAR, S.birthday, GETDATE())) as "average_age"
From Membership M INNER JOIN Student S ON M.student_id = S.student_id
FULL OUTER JOIN (Select M.course_id, 
COUNT(M.student_id) as "q_students_in_range"
From Membership M INNER JOIN Student S ON M.student_id = S.student_id
WHERE DATEDIFF(YEAR, S.birthday, GETDATE()) BETWEEN @edadInicio AND @edadFinal
GROUP BY M.course_id) AR ON AR.course_id = M.course_id
WHERE M.course_id = @course_id
GROUP BY M.course_id, AR.q_students_in_range);
go


--Para el curso 2: Rango de edad 12 - 17
Select EA.course_id, EA.q_students_in_range, EA.average_age
From EDAD_ALUMNOS_CURSO(2, 12, 17) EA;
go

--Para el curso 2: Rando de edad 19 - 24
Select EA.course_id, EA.q_students_in_range, EA.average_age
From EDAD_ALUMNOS_CURSO(2, 19, 24) EA;
go


--3. El curso con el mejor y el peor promedio de notas en tal año. (Procedimiento)

CREATE FUNCTION AVERAGE_GRADE_COURSE(@year INT) RETURNS TABLE
AS
RETURN (Select C.course_id, AVG(((100 * SQ.score_achieved)/Q.max_score)) as "achieved_percentage"
From Student_Quiz SQ JOIN Quiz Q ON Q.quiz_id = SQ.quiz_id
JOIN Lecture Lc ON Q.lecture_id = Lc.lecture_id
JOIN Lesson L ON Lc.lesson_id = L.lesson_id
JOIN Module M ON L.module_id = M.module_id
JOIN Course C ON M.course_id = c.course_id
JOIN Membership Mb ON Mb.course_id = C.course_id
Where YEAR(Mb.enrollment_date) = @year 
Group by C.course_id);
go

CREATE PROCEDURE MAX_MIN_ACHIEVED_COURSE
@year INT
AS
Select G.course_id, G.achieved_percentage
From AVERAGE_GRADE_COURSE(@year) G
WHERE G.achieved_percentage = (Select MAX(G.achieved_percentage) From AVERAGE_GRADE_COURSE(@year) G)
OR G.achieved_percentage = (Select MIN(G.achieved_percentage) From AVERAGE_GRADE_COURSE(@year) G)
GROUP BY G.achieved_percentage, G.course_id
Order by 2 desc;
go

exec MAX_MIN_ACHIEVED_COURSE 2019;
go


--4. Actualizar fecha de nacimiento del alumno siempre y cuando sea una fecha distinta a la actual (Trigger)

CREATE TRIGGER BIRTHDAY_BU ON Student
FOR UPDATE
AS
IF (Select I.birthday From inserted I) = (Select D.birthday From deleted D)
BEGIN
ROLLBACK TRANSACTION
PRINT 'El estudiante ya tiene esa fecha de cumpleanhos'
END
ELSE
PRINT 'Se ha actualizado correctamente la fecha de cumpleanhos';
go

UPDATE Student Set birthday = '1997-09-09' Where  student_id = 1;
UPDATE Student Set birthday = '1997-09-11' Where  student_id = 1;
UPDATE Student Set birthday = '1997-09-11' Where  student_id = 1;
UPDATE Student Set birthday = '1997-09-10' Where  student_id = 1;
go


-- Cleanup

drop function dbo.P_ALUMNOS_APROBADOS;
drop function dbo.COURSE_APPROVED_EVOLUTION;
drop function dbo.EDAD_ALUMNOS_CURSO;
drop function dbo.AVERAGE_GRADE_COURSE;
drop procedure dbo.MAX_MIN_ACHIEVED_COURSE;
drop trigger dbo.BIRTHDAY_BU;
go

rollback;