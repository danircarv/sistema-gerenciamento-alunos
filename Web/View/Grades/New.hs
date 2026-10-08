module Web.View.Grades.New where
import Web.View.Prelude

data NewView = NewView { grade :: Grade }

instance View NewView where
    html NewView { .. } = [hsx|
        {breadcrumb}
        <h1>New Grade</h1>
        {renderForm grade}
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Grades" GradesAction
                , breadcrumbText "New Grade"
                ]

renderForm :: Grade -> Html
renderForm grade = formFor grade [hsx|
    {- enrollmentId needs to be a selectField -}
        {(textField #enrollmentId)}
    {(textField #description) { placeholder = "Prova 1" }}
    {(numberField #value) { additionalAttributes = [("step", "0.01")], helpText = "0 a 10" }}
    {(numberField #weight) { additionalAttributes = [("step", "0.01")], helpText = "Peso na média ponderada (padrão 1)" }}
    {submitButton}

|]
