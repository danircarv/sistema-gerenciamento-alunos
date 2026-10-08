module Application.Domain.Validacao
    ( notaMinima
    , notaMaxima
    , pesoMaximo
    , validarNota
    , validarPeso
    , validarNaoVazio
    , validarEmail
    , validarRa
    , validarSemestre
    , validarAvaliacao
    , mensagemErro
    ) where

import IHP.Prelude
import Data.Char (isDigit)
import qualified Data.Text as Text
import Application.Domain.Types

notaMinima, notaMaxima, pesoMaximo :: Double
notaMinima = 0
notaMaxima = 10
pesoMaximo = 10

validarNota :: Double -> Either ErroValidacao Double
validarNota valor
    | valor >= notaMinima && valor <= notaMaxima = Right valor
    | otherwise = Left (NotaForaDoIntervalo valor)

validarPeso :: Double -> Either ErroValidacao Double
validarPeso valor
    | valor > 0 && valor <= pesoMaximo = Right valor
    | otherwise = Left (PesoInvalido valor)

validarNaoVazio :: Text -> Text -> Either ErroValidacao Text
validarNaoVazio campo valor
    | Text.null limpo = Left (CampoVazio campo)
    | otherwise = Right limpo
  where
    limpo = Text.strip valor

validarEmail :: Text -> Either ErroValidacao Text
validarEmail valor = case Text.splitOn "@" limpo of
    [usuario, dominio]
        | not (Text.null usuario)
        , "." `Text.isInfixOf` dominio
        , not ("." `Text.isPrefixOf` dominio)
        , not ("." `Text.isSuffixOf` dominio)
        -> Right (Text.toLower limpo)
    _ -> Left (EmailInvalido valor)
  where
    limpo = Text.strip valor

validarRa :: Text -> Either ErroValidacao Text
validarRa valor
    | Text.length limpo == 7 && Text.all isDigit limpo = Right limpo
    | otherwise = Left (RaInvalido valor)
  where
    limpo = Text.strip valor

validarSemestre :: Text -> Either ErroValidacao Text
validarSemestre valor = case Text.splitOn "." limpo of
    [ano, periodo]
        | Text.length ano == 4
        , Text.all isDigit ano
        , periodo `elem` ["1", "2"]
        -> Right limpo
    _ -> Left (SemestreInvalido valor)
  where
    limpo = Text.strip valor

validarAvaliacao :: Avaliacao -> Either ErroValidacao Avaliacao
validarAvaliacao Avaliacao { descricao, nota, peso } = do
    descricaoValida <- validarNaoVazio "descrição" descricao
    notaValida <- validarNota nota
    pesoValido <- validarPeso peso
    pure Avaliacao { descricao = descricaoValida, nota = notaValida, peso = pesoValido }

mensagemErro :: ErroValidacao -> Text
mensagemErro = \case
    CampoVazio campo -> "O campo " <> campo <> " é obrigatório"
    NotaForaDoIntervalo valor -> "A nota deve estar entre 0 e 10 (recebido: " <> mostrar valor <> ")"
    PesoInvalido valor -> "O peso deve ser maior que 0 e no máximo 10 (recebido: " <> mostrar valor <> ")"
    EmailInvalido _ -> "Informe um e-mail válido, por exemplo nome@email.com"
    RaInvalido _ -> "A matrícula deve ter 7 dígitos, por exemplo 2026001"
    SemestreInvalido _ -> "Use o formato AAAA.S, por exemplo 2026.2"
    QuantidadeDeNotasIncorreta esperado recebido ->
        "Eram esperadas " <> tshow esperado <> " notas, mas foram informadas " <> tshow recebido
  where
    mostrar = Text.replace "." "," . tshow
