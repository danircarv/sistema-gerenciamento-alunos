module Application.Helper.Controller
    ( validarCom
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
