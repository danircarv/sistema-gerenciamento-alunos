module Application.Domain.Acesso
    ( Recurso (..)
    , Operacao (..)
    , podeAcessar
    , descreverPapel
    , descreverRecurso
    ) where

import IHP.Prelude
import Generated.Enums (UserRole (..))

data Recurso
    = Alunos
    | Cursos
    | Matriculas
    | Notas
    deriving (Eq, Show, Enum, Bounded)

data Operacao
    = Ler
    | Escrever
    deriving (Eq, Show, Enum, Bounded)

podeAcessar :: UserRole -> Recurso -> Operacao -> Bool
podeAcessar Admin _ _ = True
podeAcessar Professor _ Ler = True
podeAcessar Professor Notas Escrever = True
podeAcessar Professor _ Escrever = False

descreverPapel :: UserRole -> Text
descreverPapel Admin = "Administrador"
descreverPapel Professor = "Professor"

descreverRecurso :: Recurso -> Text
descreverRecurso Alunos = "alunos"
descreverRecurso Cursos = "cursos"
descreverRecurso Matriculas = "matrículas"
descreverRecurso Notas = "notas"
