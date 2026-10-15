module Web.View.Courses.Show where
import Web.View.Prelude

data ShowView = ShowView { course :: Course, matriculas :: [Matricula], resumo :: ResumoCurso }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>{course.code} · {course.name}</h1>

        <div class="row g-3 mb-4">
            {indicador "Matriculados" (tshow resumo.matriculados) "length . filter"}
            {indicador "Média da turma" (formatarMedia resumo.mediaDaTurma) "map + filter + foldl'"}
            {indicador "Aprovados" (tshow resumo.aprovadosNaTurma) "filter"}
            {indicador "Maior média" (formatarMedia medias.maior) "foldl' (max)"}
            {indicador "Menor média" (formatarMedia medias.menor) "foldl' (min)"}
            {indicador "Notas lançadas" (tshow (length (todasAsAvaliacoes matriculas))) "concatMap avaliacoes"}
        </div>

        <h2 class="h5">Alunos da turma</h2>
        <table class="table">
            <thead>
                <tr><th>Aluno</th><th>Semestre</th><th>Notas</th><th>Média</th><th>Situação</th></tr>
            </thead>
            <tbody>{forEach matriculas renderLinha}</tbody>
        </table>
    |]
        where
            medias = estatisticas (mediasComNota matriculas)
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Courses" CoursesAction
                            , breadcrumbText "Show Course"
                            ]

renderLinha :: Matricula -> Html
renderLinha matricula@Matricula { aluno = Aluno { nomeAluno }, semestre, avaliacoes } = [hsx|
    <tr>
        <td>{nomeAluno}</td>
        <td>{semestre}</td>
        <td>{notasEmTexto avaliacoes}</td>
        <td>{formatarMedia (mediaDaMatricula matricula)}</td>
        <td>{renderSituacao (situacaoDaMatricula matricula)}</td>
    </tr>
|]
