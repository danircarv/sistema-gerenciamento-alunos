module Application.Domain.Media
    ( mediaSimples
    , mediaPonderada
    , termosDaMedia
    , mediaDaMatricula
    , corteAprovacao
    , corteRecuperacao
    , classificarCom
    , classificar
    , situacaoDaMatricula
    , calculadoraComPesos
    , mediaProvasETrabalho
    , arredondar
    , arredondarNota
    , formatarNota
    , formatarMedia
    , descreverSituacao
    , resumirAvaliacoes
    , notasAbaixoDe
    , alunosPorSituacao
    , boletim
    , contarPorSituacao
    ) where

import IHP.Prelude
import Numeric (showFFloat)
import qualified Data.Text as Text
import Application.Domain.Types
import Application.Domain.Validacao (validarNota, validarPeso)

mediaSimples :: [Double] -> Maybe Double
mediaSimples [] = Nothing
mediaSimples notas = Just (sum notas / fromIntegral (length notas))

mediaPonderada :: [Avaliacao] -> Maybe Double
mediaPonderada avaliacoes = do
    (_, _, media) <- termosDaMedia avaliacoes
    pure media

termosDaMedia :: [Avaliacao] -> Maybe (Double, Double, Double)
termosDaMedia avaliacoes
    | somaDosPesos <= 0 = Nothing
    | otherwise = Just (somaPonderada, somaDosPesos, somaPonderada / somaDosPesos)
  where
    somaPonderada = sum [nota * peso | Avaliacao { nota, peso } <- avaliacoes]
    somaDosPesos = sum [peso | Avaliacao { peso } <- avaliacoes]

mediaDaMatricula :: Matricula -> Maybe Double
mediaDaMatricula Matricula { avaliacoes } = mediaPonderada avaliacoes

corteAprovacao, corteRecuperacao :: Double
corteAprovacao = 7
corteRecuperacao = 5

-- A média é arredondada antes da comparação para que 6,999999 vindo de ponto
-- flutuante conte como 7,00.
classificarCom :: Double -> Double -> Maybe Double -> Situacao
classificarCom _ _ Nothing = SemNotas
classificarCom aprovacao recuperacao (Just media)
    | arredondada >= aprovacao = Aprovado
    | arredondada >= recuperacao = Recuperacao
    | otherwise = Reprovado
  where
    arredondada = arredondarNota media

classificar :: Maybe Double -> Situacao
classificar = classificarCom corteAprovacao corteRecuperacao

situacaoDaMatricula :: Matricula -> Situacao
situacaoDaMatricula = classificar . mediaDaMatricula

calculadoraComPesos :: [Double] -> [Double] -> Either ErroValidacao Double
calculadoraComPesos pesos = \notas ->
    if length notas /= length pesos
        then Left (QuantidadeDeNotasIncorreta (length pesos) (length notas))
        else do
            notasValidas <- mapM validarNota notas
            pesosValidos <- mapM validarPeso pesos
            let avaliacoes = zipWith (Avaliacao "") notasValidas pesosValidos
            maybe (Left (QuantidadeDeNotasIncorreta (length pesos) 0)) Right (mediaPonderada avaliacoes)

mediaProvasETrabalho :: [Double] -> Either ErroValidacao Double
mediaProvasETrabalho = calculadoraComPesos [3, 3, 4]

-- Arredondamento escolar: o 5 sobe (6,625 vira 6,63). O 'round' do Haskell
-- arredonda o 5 para o par mais próximo e daria 6,62.
arredondar :: Int -> Double -> Double
arredondar casas valor = fromIntegral (floor (valor * fator + 0.5) :: Integer) / fator
  where
    fator = 10 ^ casas

arredondarNota :: Double -> Double
arredondarNota = arredondar 2

formatarNota :: Double -> Text
formatarNota valor = Text.replace "." "," (Text.pack (showFFloat (Just 2) (arredondarNota valor) ""))

formatarMedia :: Maybe Double -> Text
formatarMedia = maybe "—" formatarNota

descreverSituacao :: Situacao -> Text
descreverSituacao Aprovado = "Aprovado"
descreverSituacao Recuperacao = "Recuperação"
descreverSituacao Reprovado = "Reprovado"
descreverSituacao SemNotas = "Sem notas"

resumirAvaliacoes :: [Avaliacao] -> Text
resumirAvaliacoes [] = "Nenhuma nota lançada"
resumirAvaliacoes [Avaliacao { descricao, nota }] = "1 nota: " <> descricao <> " (" <> formatarNota nota <> ")"
resumirAvaliacoes avaliacoes@(Avaliacao { nota = primeira } : _) =
    tshow (length avaliacoes) <> " notas, maior " <> formatarNota maior <> ", menor " <> formatarNota menor
  where
    notas = [nota | Avaliacao { nota } <- avaliacoes]
    maior = foldr max primeira notas
    menor = foldr min primeira notas

notasAbaixoDe :: Double -> [Avaliacao] -> [Avaliacao]
notasAbaixoDe limite avaliacoes = [avaliacao | avaliacao@Avaliacao { nota } <- avaliacoes, nota < limite]

alunosPorSituacao :: Situacao -> [Matricula] -> [Text]
alunosPorSituacao situacao matriculas =
    [ nomeAluno
    | matricula@Matricula { aluno = Aluno { nomeAluno } } <- matriculas
    , situacaoDaMatricula matricula == situacao
    ]

boletim :: [Matricula] -> [(Text, Text, Maybe Double, Situacao)]
boletim matriculas =
    [ (nomeAluno, nomeCurso, media, classificar media)
    | Matricula { aluno = Aluno { nomeAluno }, curso = Curso { nomeCurso }, avaliacoes } <- matriculas
    , let media = mediaPonderada avaliacoes
    ]

contarPorSituacao :: [Matricula] -> [(Situacao, Int)]
contarPorSituacao matriculas =
    [ (situacao, length [() | matricula <- matriculas, situacaoDaMatricula matricula == situacao])
    | situacao <- [minBound .. maxBound]
    ]
