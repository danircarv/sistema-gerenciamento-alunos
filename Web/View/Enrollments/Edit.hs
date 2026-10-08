module Web.View.Enrollments.Edit where
import Web.View.Prelude

data EditView = EditView { enrollment :: Enrollment, students :: [Student], courses :: [Course] }

instance View EditView where
    html EditView { .. } = [hsx|
        {breadcrumb}
        <h1>Edit Enrollment</h1>
        {renderForm enrollment students courses}
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Enrollments" EnrollmentsAction
                , breadcrumbText "Edit Enrollment"
                ]

renderForm :: Enrollment -> [Student] -> [Course] -> Html
renderForm enrollment students courses = formFor enrollment [hsx|
    {(selectField #studentId students) { fieldLabel = "Student" }}
    {(selectField #courseId courses) { fieldLabel = "Course" }}
    {(textField #semester) { placeholder = "2026.2" }}
    {submitButton}

|]
