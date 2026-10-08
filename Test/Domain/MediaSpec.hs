module Test.Domain.MediaSpec where

import Test.Hspec
import IHP.Prelude
import Application.Domain.Types
import Application.Domain.Media

aproximadamente :: Double -> Maybe Double -> Bool
aproximadamente esperado (Just valor) = abs (valor - esperado) < 1e-9
aproximadamente _ Nothing = False

avaliacao :: Double -> Double -> Avaliacao
avaliacao = Avaliacao "nota"

ana, bruno, carla :: Aluno
ana = Aluno { nomeAluno = "Ana", emailAluno = "ana@email.com", ra = "2026001" }
bruno = Aluno { nomeAluno = "Bruno", emailAluno = "bruno@email.com", ra = "2026002" }
carla = Aluno { nomeAluno = "Carla", emailAluno = "carla@email.com", ra = "2026003" }

pf :: Curso
pf = Curso { codigoCurso = "PF101", nomeCurso = "Programação Funcional" }

matriculaCom :: Aluno -> [Avaliacao] -> Matricula
matriculaCom aluno avaliacoes = Matricula { aluno, curso = pf, semestre = "2026.2", avaliacoes }

tests :: Spec
tests = describe "Application.Domain.Media" do
    describe "mediaSimples" do
        it "calcula a média aritmética" do
            mediaSimples [8, 7.5, 9] `shouldSatisfy` aproximadamente 8.166666666666666
        it "não tem média sem notas" do
            mediaSimples [] `shouldBe` Nothing

    describe "mediaPonderada" do
        it "pondera cada nota pelo seu peso" do
            mediaPonderada [avaliacao 8 3, avaliacao 6 3, avaliacao 9 4] `shouldSatisfy` aproximadamente 7.8
        it "com pesos iguais é a média simples" do
            mediaPonderada [avaliacao 8 1, avaliacao 7.5 1, avaliacao 9 1] `shouldBe` mediaSimples [8, 7.5, 9]
        it "não tem média sem notas" do
            mediaPonderada [] `shouldBe` Nothing
        it "expõe os termos da conta" do
            termosDaMedia [avaliacao 8 3, avaliacao 6 1] `shouldBe` Just (30, 4, 7.5)

    describe "classificar" do
        it "aprova com média 7 ou mais" do
            classificar (Just 7) `shouldBe` Aprovado
        it "manda para recuperação entre 5 e 7" do
            classificar (Just 6.99) `shouldBe` Recuperacao
            classificar (Just 5) `shouldBe` Recuperacao
        it "reprova abaixo de 5" do
            classificar (Just 4.99) `shouldBe` Reprovado
        it "sem notas não tem situação definida" do
            classificar Nothing `shouldBe` SemNotas
        it "arredonda antes de comparar (6,9999999 conta como 7,00)" do
            classificar (Just 6.9999999) `shouldBe` Aprovado
        it "aceita outros cortes por aplicação parcial" do
            let classificarPosGraduacao = classificarCom 8 6
            classificarPosGraduacao (Just 7.5) `shouldBe` Recuperacao

    describe "calculadoraComPesos" do
        it "guarda os pesos e só recebe as notas" do
            let calcular = calculadoraComPesos [1, 2]
            fmap Just (calcular [4, 7]) `shouldSatisfy` either (const False) (aproximadamente 6)
        it "mediaProvasETrabalho usa pesos 3, 3 e 4" do
            fmap Just (mediaProvasETrabalho [8, 6, 9]) `shouldSatisfy` either (const False) (aproximadamente 7.8)
        it "recusa quantidade errada de notas" do
            mediaProvasETrabalho [8, 6] `shouldBe` Left (QuantidadeDeNotasIncorreta 3 2)
        it "recusa nota fora do intervalo" do
            mediaProvasETrabalho [8, 11, 9] `shouldBe` Left (NotaForaDoIntervalo 11)

    describe "formatação" do
        it "usa duas casas e vírgula" do
            formatarNota 8.166666 `shouldBe` "8,17"
            formatarNota 7 `shouldBe` "7,00"
        it "arredonda o 5 para cima (arredondamento escolar)" do
            formatarNota 6.625 `shouldBe` "6,63"
            arredondarNota 8.125 `shouldBe` 8.13
        it "mostra traço quando não há média" do
            formatarMedia Nothing `shouldBe` "—"
        it "resume a lista conforme o seu formato" do
            resumirAvaliacoes [] `shouldBe` "Nenhuma nota lançada"
            resumirAvaliacoes [Avaliacao "Prova 1" 8 1] `shouldBe` "1 nota: Prova 1 (8,00)"
            resumirAvaliacoes [avaliacao 8 1, avaliacao 5.5 1, avaliacao 9 1] `shouldBe` "3 notas, maior 9,00, menor 5,50"

    describe "relatórios" do
        let matriculas =
                [ matriculaCom ana [avaliacao 8 1, avaliacao 9 1]
                , matriculaCom bruno [avaliacao 6 1]
                , matriculaCom carla []
                ]
        it "filtra notas abaixo de um limite" do
            notasAbaixoDe 7 [avaliacao 8 1, avaliacao 6 1, avaliacao 4 1] `shouldBe` [avaliacao 6 1, avaliacao 4 1]
        it "lista alunos por situação" do
            alunosPorSituacao Aprovado matriculas `shouldBe` ["Ana"]
            alunosPorSituacao Recuperacao matriculas `shouldBe` ["Bruno"]
            alunosPorSituacao SemNotas matriculas `shouldBe` ["Carla"]
        it "monta o boletim" do
            boletim matriculas `shouldBe`
                [ ("Ana", "Programação Funcional", Just 8.5, Aprovado)
                , ("Bruno", "Programação Funcional", Just 6, Recuperacao)
                , ("Carla", "Programação Funcional", Nothing, SemNotas)
                ]
        it "conta matrículas por situação" do
            contarPorSituacao matriculas `shouldBe` [(Aprovado, 1), (Recuperacao, 1), (Reprovado, 0), (SemNotas, 1)]
