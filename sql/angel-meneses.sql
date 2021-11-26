-- Initialize
use coursera_db;
go

begin transaction;
go

-- 1. Añadir una nueva columna 'Edad' en la tabla Student. 
-- Luego, llenar esa columna con las edades de los estudiantes cada vez que ellos registren su fecha de nacimiento en su información.
-- Para aquellos que ya tienen registrada la fecha, actualizar el campo automáticamente

ALTER TABLE Student ADD Age INT;
go

CREATE TRIGGER TX_SettingAge ON Student
FOR UPDATE
AS
UPDATE Student 
SET Age = DATEDIFF(YEAR, birthday, CURRENT_TIMESTAMP)
WHERE birthday IS NOT NULL AND Age IS NULL
go

UPDATE Student SET birthday = '2003-01-18' WHERE student_id = 3;
UPDATE Student SET birthday = '2003-05-11' WHERE student_id = 5;
UPDATE Student SET birthday = '2005-12-03' WHERE student_id = 7; 
go


-- 2. Coursera quiere saber quién fue el estudiante más joven que completó más cursos en un periodo de tiempo (entre 2 fechas)
-- (función + subqueries)
-- Ejecutar el trigger del inciso 1 (trigger) para que esta función puede ejecutar sin ningún problema.

CREATE FUNCTION BestYoungestStudent(@start DATE, @end DATE) RETURNS TABLE
AS
RETURN(SELECT S.fullname as "StudentName", S.Age , COUNT(M.course_id) AS "FinishedCourses"
FROM Membership M INNER JOIN Student S ON  M.student_id = S.student_id
WHERE M.finished_course = 1 AND M.enrollment_date BETWEEN @start AND @end AND S.birthday IS NOT NULL
GROUP BY S.fullname, S.Age
HAVING COUNT(M.course_id) >= (SELECT MAX(ECT.FinishedCourses)
FROM (SELECT S.fullname as "StudentName", COUNT(M.course_id) AS "FinishedCourses"
FROM Membership M INNER JOIN Student S ON  M.student_id = S.student_id
WHERE M.finished_course = 1 AND M.enrollment_date BETWEEN @start AND @end AND S.birthday IS NOT NULL
GROUP BY S.fullname) ECT)
AND S.Age <= (SELECT MIN(ECT.Age)
FROM (SELECT S.fullname as "StudentName", S.Age
FROM Membership M INNER JOIN Student S ON  M.student_id = S.student_id
WHERE M.finished_course = 1 AND M.enrollment_date BETWEEN @start AND @end AND S.birthday IS NOT NULL) ECT));
go

SELECT E.StudentName, E.FinishedCourses, E.Age 
FROM BestYoungestStudent('2021-01-01', '2021-11-26') E;
go

-- 3. Coursera quiere conocer qué institución ofrece los mejores contenido a los estudiantes. 
-- Esta denominación se obtiene calculando el promedio del rating de contenido de los cursos pertenecientes a las instituciones afiliadas 
-- (procedimiento)


CREATE PROCEDURE BestInstitution
AS 
SELECT I.name AS "Institucion", ROUND(AVG(C.content_rating),2) AS "BestRating"
FROM Course C INNER JOIN Institution I ON C.institution_id = I.institution_id
GROUP BY I.name
HAVING AVG(C.content_rating) >= (SELECT MAX(R.avgRating)
FROM (SELECT I.name, AVG(C.content_rating) AS "avgRating"
FROM Course C INNER JOIN Institution I ON C.institution_id = I.institution_id
GROUP BY I.name) R);
go

EXEC BestInstitution;
go

-- 4. Coursera desea saber qué cursos pertenecen a la categoría más difícil entre las existentes (la que tiene el promedio más bajo de notas aprobatorias)
-- De esa manera, poder actualizar el tipo de curso al número 10, indicador de la máxima dificultad entre los cursos.  
-- (subqueries)

UPDATE Course 
SET course_type = 10
WHERE category_id = (SELECT C.category_id
FROM Course C INNER JOIN (SELECT Ca.category_id AS "CategoryID", AVG(Ce.grade_achieved) AS "AverageGrade"
FROM Certificate Ce INNER JOIN Membership M ON Ce.certificate_id = M.certificate_code
INNER JOIN Course Co ON M.course_id = Co.course_id
INNER JOIN Category Ca ON Co.category_id = Ca.category_id
GROUP BY Ca.category_id 
HAVING AVG(Ce.grade_achieved) <= (SELECT MIN(Cat.AverageGrade)
FROM (SELECT Ca.category_id AS "CategoryID", AVG(Ce.grade_achieved) AS "AverageGrade"
FROM Certificate Ce INNER JOIN Membership M ON Ce.certificate_id = M.certificate_code
INNER JOIN Course Co ON M.course_id = Co.course_id
INNER JOIN Category Ca ON Co.category_id = Ca.category_id
GROUP BY Ca.category_id) Cat)) T ON C.category_id = T.CategoryID); 

SELECT C.category_id, C.course_id, C.name, C.course_type
FROM Course C
WHERE C.course_type = 10;

-- Cleanup
DROP TRIGGER TX_SettingAge;
DROP FUNCTION BestYoungestStudent;
DROP PROCEDURE BestInstitution;
go

rollback;