module Web.View.Enrollments.New where
import Web.View.Prelude

data NewView = NewView { enrollment :: Enrollment, students :: [Student], courses :: [Course] }

instance View NewView where
    html NewView { .. } = [hsx|
        {breadcrumb}
        <h1>New Enrollment</h1>
        {renderForm enrollment students courses}
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Enrollments" EnrollmentsAction
                , breadcrumbText "New Enrollment"
                ]

renderForm :: Enrollment -> [Student] -> [Course] -> Html
renderForm enrollment students courses = formFor enrollment [hsx|
    {(selectField #studentId students) { fieldLabel = "Student" }}
    {(selectField #courseId courses) { fieldLabel = "Course" }}
    {(textField #semester) { placeholder = "2026.2" }}
    {submitButton}

|]
