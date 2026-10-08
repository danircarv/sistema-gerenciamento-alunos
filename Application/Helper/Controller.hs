module Application.Helper.Controller
    ( validarCom
    , validarUnico
    , module Application.Domain.Types
    , module Application.Domain.Validacao
    , module Application.Domain.Media
    , module Application.Domain.Conversao
    ) where

import IHP.ControllerPrelude
import Application.Domain.Types
import Application.Domain.Validacao
import Application.Domain.Media
import Application.Domain.Conversao

-- Here you can add functions which are available in all your controllers

-- | Adapta uma validação pura do domínio para um validador de campo do IHP,
-- por exemplo @validateField #value (validarCom validarNota)@.
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
