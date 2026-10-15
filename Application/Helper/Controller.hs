module Application.Helper.Controller
    ( validarCom
    , validarUnico
    , carregarMatriculas
    , module Application.Domain.Types
    , module Application.Domain.Validacao
    , module Application.Domain.Media
    , module Application.Domain.Conversao
    , module Application.Domain.Acesso
    , module Application.Domain.Relatorio
    ) where

import IHP.ControllerPrelude
import Generated.Types
import Application.Domain.Types
import Application.Domain.Validacao
import Application.Domain.Media
import Application.Domain.Conversao
import Application.Domain.Acesso
import Application.Domain.Relatorio

validarCom :: (valor -> Either ErroValidacao resultado) -> valor -> ValidatorResult
validarCom validar valor = case validar valor of
    Right _ -> Success
    Left erro -> Failure (mensagemErro erro)

-- | Checa no banco se o valor já existe, mas só quando o campo passou nas outras
-- validações. 'withCustomErrorMessageIO' troca qualquer erro do campo pela mensagem
-- dada, então sem esta guarda um e-mail mal formatado apareceria como "já cadastrado".
validarUnico campo mensagem record = case getValidationFailure campo record of
    Just _ -> pure record
    Nothing -> withCustomErrorMessageIO mensagem validateIsUnique campo record

carregarMatriculas :: (?modelContext :: ModelContext) => IO [Matricula]
carregarMatriculas = do
    students <- query @Student |> fetch
    courses <- query @Course |> fetch
    enrollments <- query @Enrollment |> fetch
    grades <- query @Grade |> fetch
    pure (montarMatriculas students courses enrollments grades)
