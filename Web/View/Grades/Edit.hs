module Web.View.Grades.Edit where
import Web.View.Prelude

data EditView = EditView { grade :: Grade }

instance View EditView where
    html EditView { .. } = [hsx|
        {breadcrumb}
        <h1>Edit Grade</h1>
        {renderForm grade}
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Grades" GradesAction
                , breadcrumbText "Edit Grade"
                ]

renderForm :: Grade -> Html
renderForm grade = formFor grade [hsx|
    {- enrollmentId needs to be a selectField -}
        {(textField #enrollmentId)}
    {(textField #description)}
    {(numberField #value) { additionalAttributes = [("step", "0.01")], helpText = "0 a 10" }}
    {(numberField #weight) { additionalAttributes = [("step", "0.01")], helpText = "Peso na média ponderada (padrão 1)" }}
    {submitButton}

|]
