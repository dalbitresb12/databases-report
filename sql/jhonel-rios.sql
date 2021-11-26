-- Initialize

use coursera_db;
go

begin transaction;
go

-- Función: Mostrar los cursos que han sido más veces completados y la institución que los brinda
-- teniendo en cuenta un determinado país y el año de inscripción en el curso.
CREATE FUNCTION dbo.MejorCursoPais(@country varchar(15), @year int) RETURNS TABLE
AS
RETURN (
    SELECT C.name AS 'Course Name', COUNT(C.name) AS 'Times Completed', M.finished_course, I.name AS 'Institution Name'
    FROM Student S JOIN Membership M ON S.student_id = M.student_id
       JOIN Course C ON M.course_id = C.course_id
       JOIN Institution I ON C.institution_id = I.institution_id
    WHERE S.location = @country AND YEAR(M.enrollment_date) = @year AND m.finished_course = 'true'
    GROUP BY C.name, M.finished_course, I.name
    );
GO

SELECT [Course Name], [Times Completed], finished_course, [Institution Name] FROM dbo.MejorCursoPais('United States', 2017);
GO

-- Procedimiento:  Listar los cursos con una calificación menor a 2.5 estrellas de un determinada institución
CREATE PROCEDURE listaPeoresCursos
@name varchar(100)
AS
    SELECT C.name, C.course_rating, C.enrolled_students
    FROM Course C JOIN Institution I ON C.institution_id = I.institution_id
    WHERE C.course_rating < 0.5 AND I.name = @name
    ORDER BY C.course_rating;
GO

EXECUTE listaPeoresCursos 'Muxo';
GO

-- Trigger: Insertar un nuevo instructor si es que este no se encuentra registado todavía
CREATE TRIGGER TX_Instructor ON Instructor
FOR INSERT
AS
IF (SELECT COUNT(*) FROM inserted, Instructor I WHERE inserted.instructor_id = I.instructor_id) > 1
BEGIN
    Rollback transaction
    PRINT 'Este instructor ya se encuentra registrado';
END
ELSE
    PRINT 'El instructor fue registrado correctamente';
GO

-- Función con SubQuery: De las instituciones de un determinado país, mostrar el nombre de
-- los instructores, su ocupación y su calificación
CREATE FUNCTION dbo.InstructorInstitutoPais(@country varchar(2)) RETURNS TABLE
AS
RETURN (
    SELECT ITR.fullname, ITR.occupation, ITR.rating
    FROM Instructor ITR
    WHERE ITR.institution_id IN (
        SELECT I.institution_id
        FROM Institution I
        WHERE I.country = @country
        )
    );
GO

SELECT fullname, occupation, rating FROM dbo.InstructorInstitutoPais('RU')
ORDER BY 3 DESC;
GO

-- Cleanup

DROP FUNCTION dbo.MejorCursoPais;
DROP TRIGGER TX_Instructor;
DROP PROCEDURE listaPeoresCursos;
DROP FUNCTION dbo.InstructorInstitutoPais;
GO

rollback;