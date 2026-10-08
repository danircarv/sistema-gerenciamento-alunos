module Web.View.Enrollments.Index where
import Web.View.Prelude

data IndexView = IndexView { linhas :: [LinhaMatricula] }

data LinhaMatricula = LinhaMatricula
    { enrollment :: Enrollment
    , student :: Student
    , course :: Course
    , media :: Maybe Double
    }

instance View IndexView where
    html IndexView { .. } = [hsx|
        {breadcrumb}

        <h1>Index<a href={pathTo NewEnrollmentAction} class="btn btn-primary ms-4">+ New</a></h1>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Student</th>
                        <th>Course</th>
                        <th>Semester</th>
                        <th>Média</th>
                        <th>Situação</th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>{forEach linhas renderEnrollment}</tbody>
            </table>

        </div>
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Enrollments" EnrollmentsAction
                ]

renderEnrollment :: LinhaMatricula -> Html
renderEnrollment LinhaMatricula { .. } = [hsx|
    <tr>
        <td>{student.name}</td>
        <td>{course.code} · {course.name}</td>
        <td>{enrollment.semester}</td>
        <td>{formatarMedia media}</td>
        <td>{renderSituacao (classificar media)}</td>
        <td><a href={ShowEnrollmentAction enrollment.id}>Show</a></td>
        <td><a href={EditEnrollmentAction enrollment.id} class="text-muted">Edit</a></td>
        <td><a href={DeleteEnrollmentAction enrollment.id} class="js-delete text-muted">Delete</a></td>
    </tr>
|]
