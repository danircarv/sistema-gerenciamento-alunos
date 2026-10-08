module Application.Domain.Types where

import IHP.Prelude

data Aluno = Aluno
    { nomeAluno :: Text
    , emailAluno :: Text
    , ra :: Text
    } deriving (Eq, Show)

data Curso = Curso
    { codigoCurso :: Text
    , nomeCurso :: Text
    } deriving (Eq, Show)

data Avaliacao = Avaliacao
    { descricao :: Text
    , nota :: Double
    , peso :: Double
    } deriving (Eq, Show)

data Matricula = Matricula
    { aluno :: Aluno
    , curso :: Curso
    , semestre :: Text
    , avaliacoes :: [Avaliacao]
    } deriving (Eq, Show)

data Situacao
    = Aprovado
    | Recuperacao
    | Reprovado
    | SemNotas
    deriving (Eq, Show, Enum, Bounded)

data ErroValidacao
    = CampoVazio Text
    | NotaForaDoIntervalo Double
    | PesoInvalido Double
    | EmailInvalido Text
    | RaInvalido Text
    | SemestreInvalido Text
    | QuantidadeDeNotasIncorreta Int Int -- ^ Quantidade esperada, quantidade recebida
    deriving (Eq, Show)
