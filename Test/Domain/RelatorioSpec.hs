module Test.Domain.RelatorioSpec where

import Test.Hspec
import IHP.Prelude
import Application.Domain.Types
import Application.Domain.Relatorio

avaliacao :: Double -> Double -> Avaliacao
avaliacao = Avaliacao "nota"

novoAluno :: Text -> Text -> Aluno
novoAluno nome raAluno = Aluno { nomeAluno = nome, emailAluno = nome <> "@email.com", ra = raAluno }

pf, bd :: Curso
pf = Curso { codigoCurso = "PF101", nomeCurso = "Programação Funcional" }
bd = Curso { codigoCurso = "BD201", nomeCurso = "Banco de Dados" }

matricula :: Aluno -> Curso -> [Avaliacao] -> Matricula
matricula alunoDaMatricula cursoDaMatricula avaliacoes =
    Matricula { aluno = alunoDaMatricula, curso = cursoDaMatricula, semestre = "2026.2", avaliacoes }

ana, bruno, carla :: Aluno
ana = novoAluno "Ana" "2026001"
bruno = novoAluno "Bruno" "2026002"
carla = novoAluno "Carla" "2026003"

matriculas :: [Matricula]
matriculas =
    [ matricula ana pf [avaliacao 8 1, avaliacao 9 1]
    , matricula ana bd [avaliacao 4 1]
    , matricula bruno pf [avaliacao 6 1]
    , matricula carla pf []
    ]

tests :: Spec
tests = describe "Application.Domain.Relatorio" do
    it "concatMap junta as notas de todas as matrículas" do
        length (todasAsAvaliacoes matriculas) `shouldBe` 4
    it "map calcula a média de cada matrícula" do
        mediasDasMatriculas matriculas `shouldBe` [Just 8.5, Just 4, Just 6, Nothing]
    it "descarta matrículas sem nota" do
        mediasComNota matriculas `shouldBe` [8.5, 4, 6]
    it "filter seleciona por situação, aluno e curso" do
        length (matriculasNaSituacao Aprovado matriculas) `shouldBe` 1
        length (matriculasDoAluno "2026001" matriculas) `shouldBe` 2
        length (matriculasDoCurso "PF101" matriculas) `shouldBe` 3
    it "fold calcula as estatísticas numa única passada" do
        estatisticas [8.5, 4, 6] `shouldBe` Estatisticas { quantidade = 3, soma = 18.5, maior = Just 8.5, menor = Just 4 }
        estatisticas [] `shouldBe` Estatisticas 0 0 Nothing Nothing
    it "média geral é a média das médias com nota" do
        mediaGeral matriculas `shouldBe` Just (18.5 / 3)
        mediaGeral [] `shouldBe` Nothing
    it "taxa de aprovação ignora quem não tem nota" do
        taxaDeAprovacao matriculas `shouldBe` Just (1 / 3)
        taxaDeAprovacao [matricula carla pf []] `shouldBe` Nothing
    it "foldr encontra o melhor desempenho" do
        melhorDesempenho matriculas `shouldBe` Just ("Ana", 8.5)
        melhorDesempenho [] `shouldBe` Nothing
    it "resume cada curso, inclusive sem matrículas" do
        map (\ResumoCurso { matriculados, aprovadosNaTurma } -> (matriculados, aprovadosNaTurma))
            (resumoPorCurso [pf, bd, Curso "ALG100" "Algoritmos"] matriculas)
            `shouldBe` [(3, 1), (1, 0), (0, 0)]
    it "formata notas e percentuais" do
        notasEmTexto [avaliacao 8.5 1, avaliacao 6 3] `shouldBe` "8,50 · 6,00"
        notasEmTexto [] `shouldBe` "—"
        formatarPercentual (Just (2 / 3)) `shouldBe` "67%"
        formatarPercentual Nothing `shouldBe` "—"
