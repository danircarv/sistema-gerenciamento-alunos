module Web.Controller.Prelude
( module Web.Types
, module Application.Helper.Controller
, module IHP.ControllerPrelude
, module Generated.Types
, exigirAcesso
)
where

import Web.Types
import Application.Helper.Controller
import IHP.ControllerPrelude
import Generated.Types
import Web.Routes

exigirAcesso recurso operacao = do
    ensureIsUser
    let papel = currentUser.role_
    unless (podeAcessar papel recurso operacao) do
        setErrorMessage ("O perfil " <> descreverPapel papel <> " só pode consultar " <> descreverRecurso recurso <> ".")
        earlyReturn (redirectToPath "/")
