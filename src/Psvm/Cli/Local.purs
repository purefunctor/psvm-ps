module Psvm.Cli.Local where

import Prelude

import Control.Monad.Rec.Class (tailRecM)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console as Console
import Node.Process as Process


perform :: Array String -> Effect Unit
perform = tailRecM go
  where
    go argv = case Array.uncons argv of
      Just { head, tail }
        | head == "-h" || head == "--help" ->
          Console.log usage *> Process.exit 0

      _ ->
        Console.log usage *> Process.exit 1


usage :: String
usage = """Usage: psvm local [-h | --help] [VERSION]

Set a local PureScript version.
"""
