module Web.View.Enrollments.Show where
import Web.View.Prelude

data ShowView = ShowView
    { enrollment :: Enrollment
    , student :: Student
    , course :: Course
    , grades :: [Grade]
    , matricula :: Matricula
    }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>{student.name} — {course.name}</h1>
        <p class="text-muted">Semester {enrollment.semester} · Registration {student.registrationNumber}</p>

        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="card h-100"><div class="card-body">
                    <div class="text-muted small">Média ponderada</div>
                    <div class="display-6">{formatarMedia (mediaDaMatricula matricula)}</div>
                    <div class="text-muted small">{resumirAvaliacoes matricula.avaliacoes}</div>
                </div></div>
            </div>
            <div class="col-md-4">
                <div class="card h-100"><div class="card-body">
                    <div class="text-muted small">Situação</div>
                    <div class="fs-4 mt-2">{renderSituacao (situacaoDaMatricula matricula)}</div>
                    <div class="text-muted small mt-2">Aprovado ≥ 7 · Recuperação ≥ 5 · Reprovado &lt; 5</div>
                </div></div>
            </div>
            <div class="col-md-4">
                <div class="card h-100"><div class="card-body">
                    <div class="text-muted small">Cálculo</div>
                    {renderCalculo matricula.avaliacoes}
                </div></div>
            </div>
        </div>

        <h2 class="h4">Grades
            <a href={pathTo NewGradeAction <> "?enrollmentId=" <> inputValue enrollment.id} class="btn btn-primary btn-sm ms-3">+ New grade</a>
        </h2>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Description</th>
                        <th>Value</th>
                        <th>Weight</th>
                        <th>Value × Weight</th>
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
                            [ breadcrumbLink "Enrollments" EnrollmentsAction
                            , breadcrumbText "Show Enrollment"
                            ]

renderCalculo :: [Avaliacao] -> Html
renderCalculo avaliacoes = case termosDaMedia avaliacoes of
    Nothing -> [hsx|<p class="mt-2 mb-0">Lance a primeira nota para calcular a média.</p>|]
    Just (somaPonderada, somaDosPesos, media) -> [hsx|
        <p class="mt-2 mb-1"><code>Σ(nota × peso) ÷ Σ(peso)</code></p>
        <p class="mb-0"><code>{formatarNota somaPonderada} ÷ {formatarNota somaDosPesos} = {formatarNota media}</code></p>
    |]

renderGrade :: Grade -> Html
renderGrade grade = [hsx|
    <tr>
        <td>{grade.description}</td>
        <td>{formatarNota grade.value}</td>
        <td>{formatarNota grade.weight}</td>
        <td>{formatarNota (grade.value * grade.weight)}</td>
        <td><a href={EditGradeAction grade.id} class="text-muted">Edit</a></td>
        <td><a href={DeleteGradeAction grade.id} class="js-delete text-muted">Delete</a></td>
    </tr>
|]
