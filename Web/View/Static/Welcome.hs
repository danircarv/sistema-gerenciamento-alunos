module Web.View.Static.Welcome where
import Web.View.Prelude

data WelcomeView = WelcomeView
    { matriculas :: [Matricula]
    , totalAlunos :: Int
    , cursos :: [Curso]
    }

instance View WelcomeView where
    html WelcomeView { .. } = [hsx|
        <h1>Painel</h1>
        <p class="text-muted">Indicadores calculados a partir de todas as matrículas e notas.</p>

        <div class="row g-3 mb-4">
            {indicador "Alunos" (tshow totalAlunos) "fetchCount"}
            {indicador "Matrículas" (tshow (length matriculas)) "concatMap montar enrollments"}
            {indicador "Notas lançadas" (tshow (length (todasAsAvaliacoes matriculas))) "concatMap avaliacoes"}
            {indicador "Média geral" (formatarMedia (mediaGeral matriculas)) "map + filter + foldl'"}
            {indicador "Aprovação" (formatarPercentual (taxaDeAprovacao matriculas)) "filter + foldr"}
            {indicador "Melhor desempenho" (melhor (melhorDesempenho matriculas)) "foldr"}
        </div>

        <div class="row g-4">
            <div class="col-lg-7">
                <h2 class="h5">Por curso</h2>
                <table class="table">
                    <thead>
                        <tr><th>Curso</th><th>Matriculados</th><th>Média da turma</th><th>Aprovados</th></tr>
                    </thead>
                    <tbody>{forEach (resumoPorCurso cursos matriculas) renderResumo}</tbody>
                </table>
                <code class="small">map (resumoDoCurso matriculas) cursos</code>
            </div>
            <div class="col-lg-5">
                <h2 class="h5">Por situação</h2>
                <table class="table">
                    <tbody>{forEach (contarPorSituacao matriculas) renderContagem}</tbody>
                </table>
                <h2 class="h6 mt-4">Em recuperação</h2>
                {renderNomes (alunosPorSituacao Recuperacao matriculas)}
            </div>
        </div>
    |]
        where
            melhor Nothing = "—"
            melhor (Just (nome, media)) = nome <> " · " <> formatarNota media

renderResumo :: ResumoCurso -> Html
renderResumo ResumoCurso { cursoDoResumo = Curso { codigoCurso, nomeCurso }, matriculados, mediaDaTurma, aprovadosNaTurma } = [hsx|
    <tr>
        <td>{codigoCurso} · {nomeCurso}</td>
        <td>{tshow matriculados}</td>
        <td>{formatarMedia mediaDaTurma}</td>
        <td>{tshow aprovadosNaTurma}</td>
    </tr>
|]

renderContagem :: (Situacao, Int) -> Html
renderContagem (situacao, total) = [hsx|
    <tr>
        <td>{renderSituacao situacao}</td>
        <td class="text-end">{tshow total}</td>
    </tr>
|]

renderNomes :: [Text] -> Html
renderNomes [] = [hsx|<p class="text-muted">Ninguém em recuperação.</p>|]
renderNomes nomes = [hsx|<ul>{forEach nomes renderNome}</ul>|]
  where
    renderNome nome = [hsx|<li>{nome}</li>|]
