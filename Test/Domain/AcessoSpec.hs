module Test.Domain.AcessoSpec where

import Test.Hspec
import IHP.Prelude
import Generated.Enums (UserRole (..))
import Application.Domain.Acesso

tests :: Spec
tests = describe "Application.Domain.Acesso" do
    it "administrador pode ler e escrever tudo" do
        and [podeAcessar Admin recurso operacao | recurso <- [minBound .. maxBound], operacao <- [minBound .. maxBound]]
            `shouldBe` True
    it "professor pode ler tudo" do
        all (\recurso -> podeAcessar Professor recurso Ler) [minBound .. maxBound] `shouldBe` True
    it "professor só altera notas" do
        filter (\recurso -> podeAcessar Professor recurso Escrever) [minBound .. maxBound] `shouldBe` [Notas]
    it "descreve o papel" do
        map descreverPapel [Admin, Professor] `shouldBe` ["Administrador", "Professor"]
