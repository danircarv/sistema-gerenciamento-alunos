module Test.Domain.ValidacaoSpec where

import Test.Hspec
import IHP.Prelude
import Application.Domain.Types
import Application.Domain.Validacao

tests :: Spec
tests = describe "Application.Domain.Validacao" do
    describe "validarNota" do
        it "aceita os limites 0 e 10" do
            validarNota 0 `shouldBe` Right 0
            validarNota 10 `shouldBe` Right 10
        it "recusa valores fora de 0 a 10" do
            validarNota 15 `shouldBe` Left (NotaForaDoIntervalo 15)
            validarNota (-1) `shouldBe` Left (NotaForaDoIntervalo (-1))

    describe "validarPeso" do
        it "aceita pesos positivos até 10" do
            validarPeso 0.5 `shouldBe` Right 0.5
        it "recusa peso zero ou negativo" do
            validarPeso 0 `shouldBe` Left (PesoInvalido 0)
            validarPeso (-2) `shouldBe` Left (PesoInvalido (-2))

    describe "validarNaoVazio" do
        it "recusa texto só com espaços, informando o campo" do
            validarNaoVazio "nome" "   " `shouldBe` Left (CampoVazio "nome")
        it "remove espaços das pontas" do
            validarNaoVazio "nome" "  Ana  " `shouldBe` Right "Ana"

    describe "validarEmail" do
        it "aceita e normaliza um e-mail válido" do
            validarEmail " Ana@Email.com " `shouldBe` Right "ana@email.com"
        it "recusa e-mails malformados" do
            validarEmail "naoeemail" `shouldBe` Left (EmailInvalido "naoeemail")
            validarEmail "ana@email" `shouldBe` Left (EmailInvalido "ana@email")
            validarEmail "@email.com" `shouldBe` Left (EmailInvalido "@email.com")
            validarEmail "a@b@c.com" `shouldBe` Left (EmailInvalido "a@b@c.com")

    describe "validarRa" do
        it "aceita 7 dígitos" do
            validarRa "2026001" `shouldBe` Right "2026001"
        it "recusa letras ou tamanho errado" do
            validarRa "abc" `shouldBe` Left (RaInvalido "abc")
            validarRa "202600" `shouldBe` Left (RaInvalido "202600")

    describe "validarSemestre" do
        it "aceita AAAA.1 e AAAA.2" do
            validarSemestre "2026.2" `shouldBe` Right "2026.2"
        it "recusa outros formatos" do
            validarSemestre "2026.3" `shouldBe` Left (SemestreInvalido "2026.3")
            validarSemestre "26.1" `shouldBe` Left (SemestreInvalido "26.1")

    describe "validarAvaliacao" do
        it "devolve o primeiro erro encontrado" do
            validarAvaliacao (Avaliacao "" 11 0) `shouldBe` Left (CampoVazio "descrição")
            validarAvaliacao (Avaliacao "P1" 11 0) `shouldBe` Left (NotaForaDoIntervalo 11)
        it "aceita uma avaliação válida" do
            validarAvaliacao (Avaliacao " P1 " 8 2) `shouldBe` Right (Avaliacao "P1" 8 2)

    describe "mensagemErro" do
        it "gera mensagens para o formulário" do
            mensagemErro (NotaForaDoIntervalo 15) `shouldBe` "A nota deve estar entre 0 e 10 (recebido: 15,0)"
            mensagemErro (CampoVazio "nome") `shouldBe` "O campo nome é obrigatório"
