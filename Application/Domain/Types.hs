-- | Tipos do domínio acadêmico.
--
-- Os modelos de banco (Student, Course, Enrollment, Grade) são records gerados
-- pelo IHP a partir do Application/Schema.sql. Os tipos abaixo são a versão pura
-- desses modelos: não dependem do banco, então as funções de domínio podem ser
-- testadas sem IO. A conversão entre os dois fica em "Application.Domain.Conversao".
module Application.Domain.Types where

import IHP.Prelude

-- | Espelha Student.
data Aluno = Aluno
    { nomeAluno :: Text
    , emailAluno :: Text
    , ra :: Text -- ^ Registro acadêmico (coluna registration_number)
    } deriving (Eq, Show)

-- | Espelha Course.
data Curso = Curso
    { codigoCurso :: Text
    , nomeCurso :: Text
    } deriving (Eq, Show)

-- | Espelha Grade: uma nota com o seu peso na média.
data Avaliacao = Avaliacao
    { descricao :: Text
    , nota :: Double
    , peso :: Double
    } deriving (Eq, Show)

-- | Espelha Enrollment, já com as notas da matrícula.
data Matricula = Matricula
    { aluno :: Aluno
    , curso :: Curso
    , semestre :: Text
    , avaliacoes :: [Avaliacao]
    } deriving (Eq, Show)

-- | Tipo soma com a situação do aluno em uma matrícula.
data Situacao
    = Aprovado
    | Recuperacao
    | Reprovado
    | SemNotas
    deriving (Eq, Show, Enum, Bounded)

-- | Motivos pelos quais um dado de entrada pode ser recusado.
data ErroValidacao
    = CampoVazio Text
    | NotaForaDoIntervalo Double
    | PesoInvalido Double
    | EmailInvalido Text
    | RaInvalido Text
    | SemestreInvalido Text
    | QuantidadeDeNotasIncorreta Int Int -- ^ Quantidade esperada, quantidade recebida
    deriving (Eq, Show)
