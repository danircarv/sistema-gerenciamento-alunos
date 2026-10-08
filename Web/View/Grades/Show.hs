module Web.View.Grades.Show where
import Web.View.Prelude

data ShowView = ShowView { grade :: Grade }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>Show Grade</h1>
        <dl>
            <dt>Enrollment Id</dt><dd>{grade.enrollmentId}</dd>
            <dt>Description</dt><dd>{grade.description}</dd>
            <dt>Value</dt><dd>{grade.value}</dd>
        </dl>

    |]
        where
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Grades" GradesAction
                            , breadcrumbText "Show Grade"
                            ]