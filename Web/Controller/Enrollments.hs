module Web.Controller.Enrollments where

import Web.Controller.Prelude
import Web.View.Enrollments.Index
import Web.View.Enrollments.New
import Web.View.Enrollments.Edit
import Web.View.Enrollments.Show

instance Controller EnrollmentsController where
    action EnrollmentsAction = do
        enrollments <- query @Enrollment |> fetch
        render IndexView { .. }

    action NewEnrollmentAction = do
        let enrollment = newRecord
        render NewView { .. }

    action ShowEnrollmentAction { enrollmentId } = do
        enrollment <- fetch enrollmentId
        render ShowView { .. }

    action EditEnrollmentAction { enrollmentId } = do
        enrollment <- fetch enrollmentId
        render EditView { .. }

    action UpdateEnrollmentAction { enrollmentId } = do
        enrollment <- fetch enrollmentId
        enrollment
            |> buildEnrollment
            |> ifValid \case
                Left enrollment -> render EditView { .. }
                Right enrollment -> do
                    enrollment <- enrollment |> updateRecord
                    setSuccessMessage "Enrollment updated"
                    redirectTo EditEnrollmentAction { .. }

    action CreateEnrollmentAction = do
        let enrollment = newRecord @Enrollment
        enrollment
            |> buildEnrollment
            |> ifValid \case
                Left enrollment -> render NewView { .. } 
                Right enrollment -> do
                    enrollment <- enrollment |> createRecord
                    setSuccessMessage "Enrollment created"
                    redirectTo EnrollmentsAction

    action DeleteEnrollmentAction { enrollmentId } = do
        enrollment <- fetch enrollmentId
        deleteRecord enrollment
        setSuccessMessage "Enrollment deleted"
        redirectTo EnrollmentsAction

buildEnrollment enrollment = enrollment
    |> fill @'["studentId", "courseId", "semester"]
    |> validateField #semester nonEmpty
