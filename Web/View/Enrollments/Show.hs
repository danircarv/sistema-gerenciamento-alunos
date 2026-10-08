module Web.View.Enrollments.Show where
import Web.View.Prelude

data ShowView = ShowView { enrollment :: Enrollment }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>Show Enrollment</h1>
        <dl>
            <dt>Student Id</dt><dd>{enrollment.studentId}</dd>
            <dt>Course Id</dt><dd>{enrollment.courseId}</dd>
            <dt>Semester</dt><dd>{enrollment.semester}</dd>
        </dl>

    |]
        where
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Enrollments" EnrollmentsAction
                            , breadcrumbText "Show Enrollment"
                            ]