-- | Cálculo de médias, classificação e relatórios. Todas as funções são puras.
module Application.Domain.Media
    ( -- * Médias
      mediaSimples
    , mediaPonderada
    , termosDaMedia
    , mediaDaMatricula
      -- * Classificação
    , corteAprovacao
    , corteRecuperacao
    , classificarCom
    , classificar
    , situacaoDaMatricula
      -- * Calculadora com pesos fixos
    , calculadoraComPesos
    , mediaProvasETrabalho
      -- * Formatação
    , arredondar
    , arredondarNota
    , formatarNota
    , formatarMedia
    , descreverSituacao
    , resumirAvaliacoes
      -- * Relatórios
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

-- * Médias

mediaSimples :: [Double] -> Maybe Double
mediaSimples [] = Nothing
mediaSimples notas = Just (sum notas / fromIntegral (length notas))

-- | Média ponderada: soma de (nota × peso) dividida pela soma dos pesos.
--
-- É o cálculo de IMC adaptado: o IMC combina duas medidas (peso e altura) em um
-- índice e depois enquadra o índice em faixas. Aqui combinamos notas e pesos em
-- uma média e enquadramos a média em uma 'Situacao' com 'classificar'.
--
-- Devolve 'Nothing' quando não há notas, porque não existe média de uma lista vazia.
mediaPonderada :: [Avaliacao] -> Maybe Double
mediaPonderada avaliacoes = do
    (_, _, media) <- termosDaMedia avaliacoes
    pure media

-- | Os termos da conta, para exibir o cálculo na tela:
-- (soma de nota × peso, soma dos pesos, média).
termosDaMedia :: [Avaliacao] -> Maybe (Double, Double, Double)
termosDaMedia avaliacoes
    | somaDosPesos <= 0 = Nothing
    | otherwise = Just (somaPonderada, somaDosPesos, somaPonderada / somaDosPesos)
  where
    somaPonderada = sum [nota * peso | Avaliacao { nota, peso } <- avaliacoes]
    somaDosPesos = sum [peso | Avaliacao { peso } <- avaliacoes]

mediaDaMatricula :: Matricula -> Maybe Double
mediaDaMatricula Matricula { avaliacoes } = mediaPonderada avaliacoes

-- * Classificação

corteAprovacao, corteRecuperacao :: Double
corteAprovacao = 7
corteRecuperacao = 5

-- | Os cortes vêm antes da média para que a função possa ser aplicada parcialmente
-- (currying), como em 'classificar'. A média é arredondada antes da comparação para
-- que 6,999999 vindo de ponto flutuante conte como 7,00.
classificarCom :: Double -> Double -> Maybe Double -> Situacao
classificarCom _ _ Nothing = SemNotas
classificarCom aprovacao recuperacao (Just media)
    | arredondada >= aprovacao = Aprovado
    | arredondada >= recuperacao = Recuperacao
    | otherwise = Reprovado
  where
    arredondada = arredondarNota media

-- | Regra do sistema: 'classificarCom' parcialmente aplicada aos cortes 7 e 5.
classificar :: Maybe Double -> Situacao
classificar = classificarCom corteAprovacao corteRecuperacao

situacaoDaMatricula :: Matricula -> Situacao
situacaoDaMatricula = classificar . mediaDaMatricula

-- * Calculadora com pesos fixos

-- | Recebe os pesos uma única vez e devolve uma função que só precisa das notas.
-- A função devolvida guarda os pesos (é uma closure), então pode ser reutilizada
-- para todos os alunos de uma disciplina.
calculadoraComPesos :: [Double] -> [Double] -> Either ErroValidacao Double
calculadoraComPesos pesos = \notas ->
    if length notas /= length pesos
        then Left (QuantidadeDeNotasIncorreta (length pesos) (length notas))
        else do
            notasValidas <- mapM validarNota notas
            pesosValidos <- mapM validarPeso pesos
            let avaliacoes = zipWith (Avaliacao "") notasValidas pesosValidos
            maybe (Left (QuantidadeDeNotasIncorreta (length pesos) 0)) Right (mediaPonderada avaliacoes)

-- | Pesos da disciplina: Prova 1 (3), Prova 2 (3) e Trabalho (4).
mediaProvasETrabalho :: [Double] -> Either ErroValidacao Double
mediaProvasETrabalho = calculadoraComPesos [3, 3, 4]

-- * Formatação

arredondar :: Int -> Double -> Double
arredondar casas valor = fromIntegral (round (valor * fator) :: Integer) / fator
  where
    fator = 10 ^ casas

arredondarNota :: Double -> Double
arredondarNota = arredondar 2

-- | Duas casas decimais com vírgula, por exemplo @8,17@.
formatarNota :: Double -> Text
formatarNota valor = Text.replace "." "," (Text.pack (showFFloat (Just 2) (arredondarNota valor) ""))

formatarMedia :: Maybe Double -> Text
formatarMedia = maybe "—" formatarNota

descreverSituacao :: Situacao -> Text
descreverSituacao Aprovado = "Aprovado"
descreverSituacao Recuperacao = "Recuperação"
descreverSituacao Reprovado = "Reprovado"
descreverSituacao SemNotas = "Sem notas"

-- | Resumo textual que depende do formato da lista (vazia, uma nota, várias notas).
resumirAvaliacoes :: [Avaliacao] -> Text
resumirAvaliacoes [] = "Nenhuma nota lançada"
resumirAvaliacoes [Avaliacao { descricao, nota }] = "1 nota: " <> descricao <> " (" <> formatarNota nota <> ")"
resumirAvaliacoes avaliacoes@(Avaliacao { nota = primeira } : _) =
    tshow (length avaliacoes) <> " notas, maior " <> formatarNota maior <> ", menor " <> formatarNota menor
  where
    notas = [nota | Avaliacao { nota } <- avaliacoes]
    maior = foldr max primeira notas
    menor = foldr min primeira notas

-- * Relatórios

notasAbaixoDe :: Double -> [Avaliacao] -> [Avaliacao]
notasAbaixoDe limite avaliacoes = [avaliacao | avaliacao@Avaliacao { nota } <- avaliacoes, nota < limite]

alunosPorSituacao :: Situacao -> [Matricula] -> [Text]
alunosPorSituacao situacao matriculas =
    [ nomeAluno
    | matricula@Matricula { aluno = Aluno { nomeAluno } } <- matriculas
    , situacaoDaMatricula matricula == situacao
    ]

-- | Uma linha por matrícula: aluno, curso, média e situação.
boletim :: [Matricula] -> [(Text, Text, Maybe Double, Situacao)]
boletim matriculas =
    [ (nomeAluno, nomeCurso, media, classificar media)
    | Matricula { aluno = Aluno { nomeAluno }, curso = Curso { nomeCurso }, avaliacoes } <- matriculas
    , let media = mediaPonderada avaliacoes
    ]

-- | Quantidade de matrículas em cada situação, na ordem em que 'Situacao' é declarada.
contarPorSituacao :: [Matricula] -> [(Situacao, Int)]
contarPorSituacao matriculas =
    [ (situacao, length [() | matricula <- matriculas, situacaoDaMatricula matricula == situacao])
    | situacao <- [minBound .. maxBound]
    ]
