module Web.Controller.Grades where

import Web.Controller.Prelude
import Web.View.Grades.Index
import Web.View.Grades.New
import Web.View.Grades.Edit
import Web.View.Grades.Show

instance Controller GradesController where
    beforeAction = exigirAcesso Notas case ?theAction of
        GradesAction -> Ler
        ShowGradeAction {} -> Ler
        _ -> Escrever

    action GradesAction = do
        grades <- query @Grade |> fetch
        render IndexView { .. }

    action NewGradeAction = do
        let grade = case paramOrNothing "enrollmentId" of
                Just enrollmentId -> newRecord @Grade |> set #enrollmentId enrollmentId
                Nothing -> newRecord @Grade
        render NewView { .. }

    action ShowGradeAction { gradeId } = do
        grade <- fetch gradeId
        render ShowView { .. }

    action EditGradeAction { gradeId } = do
        grade <- fetch gradeId
        render EditView { .. }

    action UpdateGradeAction { gradeId } = do
        grade <- fetch gradeId
        grade
            |> buildGrade
            |> ifValid \case
                Left grade -> render EditView { .. }
                Right grade -> do
                    grade <- grade |> updateRecord
                    setSuccessMessage "Grade updated"
                    redirectTo ShowEnrollmentAction { enrollmentId = grade.enrollmentId }

    action CreateGradeAction = do
        let grade = newRecord @Grade
        grade
            |> buildGrade
            |> ifValid \case
                Left grade -> render NewView { .. }
                Right grade -> do
                    grade <- grade |> createRecord
                    setSuccessMessage "Grade created"
                    redirectTo ShowEnrollmentAction { enrollmentId = grade.enrollmentId }

    action DeleteGradeAction { gradeId } = do
        grade <- fetch gradeId
        deleteRecord grade
        setSuccessMessage "Grade deleted"
        redirectTo ShowEnrollmentAction { enrollmentId = grade.enrollmentId }

buildGrade grade = grade
    |> fill @'["enrollmentId", "description", "value", "weight"]
    |> validateField #description (validarCom (validarNaoVazio "descrição"))
    |> validateField #value (validarCom validarNota)
    |> validateField #weight (validarCom validarPeso)
