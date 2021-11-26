-- Initialize
use coursera_db;
go
begin transaction;
go


--1. Países con cantidad de alumnos mayor que el promedio y la suma del nivel de experiencia que están activos o inactivos (Función)
--2. Mostrar a los alumnos (F=0, M=1, O=2, N=3) que han o no terminado (0 = no, 1 = Si) en que hayan entrado en el primer semestre del año "X" (Procedimiento)
--3. Ingresa un código de alumno y crea una columna en la membrensía donde indique la cantidad de cambios (Trigger)
--4. Mejores alumnos en promedio de calificación ordenados de mayor a menor con su país "A" en el año "X" (Subquery)



--1. Países con cantidad de alumnos mayor o igual al promedio y la suma del nivel de experiencia que están activos o inactivos (Función)

CREATE FUNCTION ESTU_ACTI_INAC(@estado int) RETURNS TABLE
AS
RETURN(
Select Count(distinct S.student_id) AS Cant_Stu, S.location AS Pais, SUM(S.experience_level) AS Nivel_Experiencia
From Student S 
where S.location != 'NULL' AND S.is_student = @estado
Group by S.location
Having Count(distinct S.student_id) >= (Select (Count (distinct S.student_id)/Count (distinct S.location)) 
From Student S 
where S.location != 'NULL') );
go

Select EAI.Cant_Stu, EAI.Nivel_Experiencia, EAI.Pais
From ESTU_ACTI_INAC('0') EAI;
go

--

Select Count(distinct S.student_id) AS Cant_Stu, S.location AS Pais, SUM(S.experience_level) AS Nivel_Experiencia
From Student S 
where S.location != 'NULL'
Group by S.location
Having Count(distinct S.student_id) >= (Select (Count (distinct S.student_id)/Count (distinct S.location)) 
From Student S 
where S.location != 'NULL');
go
--

--2. Mostrar a los alumnos (F=0, M=1, O=2, N=3) que han o no terminado (0 = no, 1 = Si) en que hayan entrado en el primer semestre del año "X" (Procedimiento)

CREATE PROCEDURE SP_ESTU_GEN_ANHO
@year int, @term int, @gen int
AS
SELECT
distinct M.student_id, S.fullname, S.gender, M.enrollment_date, M.certificate_code
From Membership M JOIN Student S on M.student_id = S.student_id
Where MONTH(M.enrollment_date) < 7 AND YEAR(M.enrollment_date) = @year
AND M.finished_course = @term AND S.gender = @gen;
go

exec SP_ESTU_GEN_ANHO 2017,0,1;
go

--3. Ingresa un código de alumno y crea una columna en la membrensía donde indique la cantidad de cambios (Trigger)

ALTER TABLE Membership ADD Cambios int; 
go

   UPDATE Membership Set Cambios = 0;
   go


CREATE TRIGGER TX_COD_ESTU ON Student
FOR UPDATE
AS
UPDATE Membership SET Cambios = Cambios + 1 FROM inserted I WHERE I.student_id = course_id;
go

--antes de la insercion
Select M.Cambios
From Membership M;
go

UPDATE Student Set fullname = 'Jorge Peres' Where student_id = 2;
go

--despues de la insercion
Select M.Cambios
From Membership M;
go


--4. Mejores alumnos en promedio de calificación ordenados de mayor a menor con su país "A" en el año "X" (Subquery)


Select distinct S.student_id, AVG(SQ.score_achieved) AS Promedio, S.location, YEAR(M.enrollment_date) AS ANHO
From Student_Quiz SQ JOIN Student S on SQ.student_id = S.student_id 
JOIN Membership M on S.student_id = M.student_id
Where YEAR(M.enrollment_date) = 2018
Group by S.student_id, S.location, M.enrollment_date
Having AVG(SQ.score_achieved) > (Select SUM(SQ.score_achieved)/Count(S.student_id) 
From Student_Quiz SQ JOIN Student S on SQ.student_id = S.student_id)
Order by 2 desc;
go


-- Cleanup
rollback;