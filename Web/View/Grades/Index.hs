module Web.View.Grades.Index where
import Web.View.Prelude

data IndexView = IndexView { grades :: [Grade] }

instance View IndexView where
    html IndexView { .. } = [hsx|
        {breadcrumb}

        <h1>Index<a href={pathTo NewGradeAction} class="btn btn-primary ms-4">+ New</a></h1>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Enrollment Id</th>
                        <th>Description</th>
                        <th>Value</th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>{forEach grades renderGrade}</tbody>
            </table>
            
        </div>
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Grades" GradesAction
                ]

renderGrade :: Grade -> Html
renderGrade grade = [hsx|
    <tr>
        <td>{grade.enrollmentId}</td>
        <td>{grade.description}</td>
        <td>{grade.value}</td>
        <td><a href={ShowGradeAction grade.id}>Show</a></td>
        <td><a href={EditGradeAction grade.id} class="text-muted">Edit</a></td>
        <td><a href={DeleteGradeAction grade.id} class="js-delete text-muted">Delete</a></td>
    </tr>
|]