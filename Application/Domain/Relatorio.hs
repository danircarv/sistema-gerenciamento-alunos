module Application.Domain.Relatorio
    ( todasAsAvaliacoes
    , mediasDasMatriculas
    , mediasComNota
    , matriculasNaSituacao
    , matriculasDoAluno
    , matriculasDoCurso
    , Estatisticas (..)
    , estatisticas
    , mediaDasEstatisticas
    , mediaGeral
    , taxaDeAprovacao
    , melhorDesempenho
    , ResumoCurso (..)
    , resumoDoCurso
    , resumoPorCurso
    , notasEmTexto
    , formatarPercentual
    ) where

import IHP.Prelude
import Data.List (foldl')
import Data.Maybe (catMaybes)
import qualified Data.Text as Text
import Application.Domain.Types
import Application.Domain.Media

todasAsAvaliacoes :: [Matricula] -> [Avaliacao]
todasAsAvaliacoes = concatMap avaliacoes

mediasDasMatriculas :: [Matricula] -> [Maybe Double]
mediasDasMatriculas = map mediaDaMatricula

mediasComNota :: [Matricula] -> [Double]
mediasComNota = catMaybes . mediasDasMatriculas

matriculasNaSituacao :: Situacao -> [Matricula] -> [Matricula]
matriculasNaSituacao situacao = filter ((== situacao) . situacaoDaMatricula)

matriculasDoAluno :: Text -> [Matricula] -> [Matricula]
matriculasDoAluno raProcurado = filter (\Matricula { aluno = Aluno { ra } } -> ra == raProcurado)

matriculasDoCurso :: Text -> [Matricula] -> [Matricula]
matriculasDoCurso codigo = filter (\Matricula { curso = Curso { codigoCurso } } -> codigoCurso == codigo)

data Estatisticas = Estatisticas
    { quantidade :: Int
    , soma :: Double
    , maior :: Maybe Double
    , menor :: Maybe Double
    } deriving (Eq, Show)

estatisticas :: [Double] -> Estatisticas
estatisticas = foldl' acumular (Estatisticas 0 0 Nothing Nothing)
  where
    acumular Estatisticas { quantidade, soma, maior, menor } valor = Estatisticas
        { quantidade = quantidade + 1
        , soma = soma + valor
        , maior = Just (maybe valor (max valor) maior)
        , menor = Just (maybe valor (min valor) menor)
        }

mediaDasEstatisticas :: Estatisticas -> Maybe Double
mediaDasEstatisticas Estatisticas { quantidade = 0 } = Nothing
mediaDasEstatisticas Estatisticas { quantidade, soma } = Just (soma / fromIntegral quantidade)

mediaGeral :: [Matricula] -> Maybe Double
mediaGeral = mediaDasEstatisticas . estatisticas . mediasComNota

taxaDeAprovacao :: [Matricula] -> Maybe Double
taxaDeAprovacao matriculas
    | total == 0 = Nothing
    | otherwise = Just (fromIntegral aprovados / fromIntegral total)
  where
    avaliadas = filter ((/= SemNotas) . situacaoDaMatricula) matriculas
    total = length avaliadas
    aprovados = foldr (\matricula n -> if situacaoDaMatricula matricula == Aprovado then n + 1 else n) (0 :: Int) avaliadas

melhorDesempenho :: [Matricula] -> Maybe (Text, Double)
melhorDesempenho = foldr escolher Nothing
  where
    escolher Matricula { aluno = Aluno { nomeAluno }, avaliacoes } atual =
        case (mediaPonderada avaliacoes, atual) of
            (Nothing, _) -> atual
            (Just media, Just (_, melhor)) | media <= melhor -> atual
            (Just media, _) -> Just (nomeAluno, media)

data ResumoCurso = ResumoCurso
    { cursoDoResumo :: Curso
    , matriculados :: Int
    , mediaDaTurma :: Maybe Double
    , aprovadosNaTurma :: Int
    } deriving (Eq, Show)

resumoDoCurso :: [Matricula] -> Curso -> ResumoCurso
resumoDoCurso matriculas cursoAlvo@Curso { codigoCurso } = ResumoCurso
    { cursoDoResumo = cursoAlvo
    , matriculados = length daTurma
    , mediaDaTurma = mediaGeral daTurma
    , aprovadosNaTurma = length (matriculasNaSituacao Aprovado daTurma)
    }
  where
    daTurma = matriculasDoCurso codigoCurso matriculas

resumoPorCurso :: [Curso] -> [Matricula] -> [ResumoCurso]
resumoPorCurso cursos matriculas = map (resumoDoCurso matriculas) cursos

notasEmTexto :: [Avaliacao] -> Text
notasEmTexto [] = "—"
notasEmTexto avaliacoes = Text.intercalate " · " (map (\Avaliacao { nota } -> formatarNota nota) avaliacoes)

formatarPercentual :: Maybe Double -> Text
formatarPercentual Nothing = "—"
formatarPercentual (Just fracao) = tshow (floor (fracao * 100 + 0.5) :: Int) <> "%"
