module Application.Helper.View
    ( classeSituacao
    , renderSituacao
    , indicador
    , module Application.Domain.Types
    , module Application.Domain.Media
    , module Application.Domain.Conversao
    , module Application.Domain.Acesso
    , module Application.Domain.Relatorio
    ) where

import IHP.ViewPrelude
import Generated.Types
import Application.Domain.Types
import Application.Domain.Media
import Application.Domain.Conversao
import Application.Domain.Acesso
import Application.Domain.Relatorio

classeSituacao :: Situacao -> Text
classeSituacao Aprovado = "bg-success"
classeSituacao Recuperacao = "bg-warning text-dark"
classeSituacao Reprovado = "bg-danger"
classeSituacao SemNotas = "bg-secondary"

renderSituacao :: Situacao -> Html
renderSituacao situacao = [hsx|<span class={"badge " <> classeSituacao situacao}>{descreverSituacao situacao}</span>|]

indicador :: Text -> Text -> Html
indicador rotulo valor = [hsx|
    <div class="col-md-4">
        <div class="card h-100"><div class="card-body">
            <div class="text-muted small">{rotulo}</div>
            <div class="fs-4">{valor}</div>
        </div></div>
    </div>
|]

instance CanSelect Student where
    type SelectValue Student = Id Student
    selectValue student = student.id
    selectLabel student = student.name <> " (" <> student.registrationNumber <> ")"

instance CanSelect Course where
    type SelectValue Course = Id Course
    selectValue course = course.id
    selectLabel course = course.code <> " · " <> course.name
