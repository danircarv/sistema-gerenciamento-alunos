module Web.Controller.Enrollments where

import Web.Controller.Prelude
import Web.View.Enrollments.Index
import Web.View.Enrollments.New
import Web.View.Enrollments.Edit
import Web.View.Enrollments.Show

instance Controller EnrollmentsController where
    beforeAction = exigirAcesso Matriculas case ?theAction of
        EnrollmentsAction -> Ler
        ShowEnrollmentAction {} -> Ler
        _ -> Escrever

    action EnrollmentsAction = do
        enrollments <- query @Enrollment |> orderByDesc #createdAt |> fetch
        students <- query @Student |> fetch
        courses <- query @Course |> fetch
        grades <- query @Grade |> fetch
        let linhas =
                [ LinhaMatricula
                    { enrollment
                    , student
                    , course
                    , media = mediaPonderada (avaliacoesDaMatricula grades enrollment.id)
                    }
                | enrollment <- enrollments
                , student <- students, student.id == enrollment.studentId
                , course <- courses, course.id == enrollment.courseId
                ]
        render IndexView { .. }

    action NewEnrollmentAction = do
        let enrollment = newRecord
        (students, courses) <- opcoesDoFormulario
        render NewView { .. }

    action ShowEnrollmentAction { enrollmentId } = do
        enrollment <- fetch enrollmentId
        student <- fetch enrollment.studentId
        course <- fetch enrollment.courseId
        grades <- query @Grade
            |> filterWhere (#enrollmentId, enrollmentId)
            |> orderBy #createdAt
            |> fetch
        let matricula = matriculaDe student course enrollment grades
        render ShowView { .. }

    action EditEnrollmentAction { enrollmentId } = do
        enrollment <- fetch enrollmentId
        (students, courses) <- opcoesDoFormulario
        render EditView { .. }

    action UpdateEnrollmentAction { enrollmentId } = do
        enrollment <- fetch enrollmentId
        enrollment
            |> buildEnrollment
            |> validarMatriculaUnica
            >>= ifValid \case
                Left enrollment -> do
                    (students, courses) <- opcoesDoFormulario
                    render EditView { .. }
                Right enrollment -> do
                    enrollment <- enrollment |> updateRecord
                    setSuccessMessage "Enrollment updated"
                    redirectTo ShowEnrollmentAction { .. }

    action CreateEnrollmentAction = do
        let enrollment = newRecord @Enrollment
        enrollment
            |> buildEnrollment
            |> validarMatriculaUnica
            >>= ifValid \case
                Left enrollment -> do
                    (students, courses) <- opcoesDoFormulario
                    render NewView { .. }
                Right enrollment -> do
                    enrollment <- enrollment |> createRecord
                    setSuccessMessage "Enrollment created"
                    redirectTo ShowEnrollmentAction { enrollmentId = enrollment.id }

    action DeleteEnrollmentAction { enrollmentId } = do
        enrollment <- fetch enrollmentId
        deleteRecord enrollment
        setSuccessMessage "Enrollment deleted"
        redirectTo EnrollmentsAction

buildEnrollment enrollment = enrollment
    |> fill @'["studentId", "courseId", "semester"]
    |> validateField #semester (validarCom validarSemestre)

opcoesDoFormulario :: (?modelContext :: ModelContext) => IO ([Student], [Course])
opcoesDoFormulario = do
    students <- query @Student |> orderBy #name |> fetch
    courses <- query @Course |> orderBy #name |> fetch
    pure (students, courses)

validarMatriculaUnica :: (?modelContext :: ModelContext) => Enrollment -> IO Enrollment
validarMatriculaUnica enrollment
    | isJust (getValidationFailure #semester enrollment) = pure enrollment
    | otherwise = do
    jaExiste <- query @Enrollment
        |> filterWhere (#studentId, enrollment.studentId)
        |> filterWhere (#courseId, enrollment.courseId)
        |> filterWhere (#semester, enrollment.semester)
        |> filterWhereNot (#id, enrollment.id)
        |> fetchExists
    pure if jaExiste
        then enrollment |> attachFailure #semester "Este aluno já está matriculado neste curso neste semestre"
        else enrollment
