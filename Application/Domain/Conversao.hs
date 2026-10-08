-- | Converte os records gerados pelo IHP (Student, Course, Enrollment, Grade)
-- nos tipos puros de "Application.Domain.Types".
module Application.Domain.Conversao
    ( alunoDeStudent
    , cursoDeCourse
    , avaliacaoDeGrade
    , avaliacoesDaMatricula
    , matriculaDe
    ) where

import IHP.Prelude
import IHP.ModelSupport (Id)
import Generated.Types
import Application.Domain.Types

alunoDeStudent :: Student -> Aluno
alunoDeStudent student = Aluno
    { nomeAluno = student.name
    , emailAluno = student.email
    , ra = student.registrationNumber
    }

cursoDeCourse :: Course -> Curso
cursoDeCourse course = Curso
    { codigoCurso = course.code
    , nomeCurso = course.name
    }

avaliacaoDeGrade :: Grade -> Avaliacao
avaliacaoDeGrade grade = Avaliacao
    { descricao = grade.description
    , nota = grade.value
    , peso = grade.weight
    }

-- | Notas que pertencem a uma matrícula, a partir de uma lista de notas do banco.
avaliacoesDaMatricula :: [Grade] -> Id Enrollment -> [Avaliacao]
avaliacoesDaMatricula grades enrollmentId =
    [avaliacaoDeGrade grade | grade <- grades, grade.enrollmentId == enrollmentId]

matriculaDe :: Student -> Course -> Enrollment -> [Grade] -> Matricula
matriculaDe student course enrollment grades = Matricula
    { aluno = alunoDeStudent student
    , curso = cursoDeCourse course
    , semestre = enrollment.semester
    , avaliacoes = avaliacoesDaMatricula grades enrollment.id
    }
