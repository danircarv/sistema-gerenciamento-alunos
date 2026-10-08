module Main where

import Test.Hspec
import IHP.Prelude

import qualified Test.Domain.MediaSpec
import qualified Test.Domain.ValidacaoSpec

main :: IO ()
main = hspec do
    Test.Domain.MediaSpec.tests
    Test.Domain.ValidacaoSpec.tests
