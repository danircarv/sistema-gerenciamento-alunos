module Main where

import Test.Hspec
import IHP.Prelude

import qualified Test.Domain.MediaSpec
import qualified Test.Domain.ValidacaoSpec
import qualified Test.Domain.AcessoSpec
import qualified Test.Domain.RelatorioSpec

main :: IO ()
main = hspec do
    Test.Domain.MediaSpec.tests
    Test.Domain.ValidacaoSpec.tests
    Test.Domain.AcessoSpec.tests
    Test.Domain.RelatorioSpec.tests
