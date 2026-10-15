module Web.View.Students.Show where
import Web.View.Prelude

data ShowView = ShowView { student :: Student, matriculas :: [Matricula] }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>{student.name}</h1>
        <p class="text-muted">{student.email} · Registration {student.registrationNumber}</p>

        <div class="row g-3 mb-4">
            {indicador "Média geral" (formatarMedia (mediaGeral matriculas)) "map + filter + foldl'"}
            {indicador "Matrículas" (tshow (length matriculas)) "filter (ra == ...)"}
            {indicador "Aprovação" (formatarPercentual (taxaDeAprovacao matriculas)) "filter + foldr"}
        </div>

        <h2 class="h5">Boletim</h2>
        <table class="table">
            <thead>
                <tr><th>Curso</th><th>Semestre</th><th>Notas</th><th>Média</th><th>Situação</th></tr>
            </thead>
            <tbody>{forEach matriculas renderLinha}</tbody>
        </table>
    |]
        where
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Students" StudentsAction
                            , breadcrumbText "Show Student"
                            ]

renderLinha :: Matricula -> Html
renderLinha matricula@Matricula { curso = Curso { codigoCurso, nomeCurso }, semestre, avaliacoes } = [hsx|
    <tr>
        <td>{codigoCurso} · {nomeCurso}</td>
        <td>{semestre}</td>
        <td>{notasEmTexto avaliacoes}</td>
        <td>{formatarMedia (mediaDaMatricula matricula)}</td>
        <td>{renderSituacao (situacaoDaMatricula matricula)}</td>
    </tr>
|]
