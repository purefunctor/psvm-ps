module Psvm.Cli.Ls where

import Prelude

import Control.Monad.Rec.Class (tailRecM)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Traversable (for_)
import Effect (Effect)
import Effect.Console as Console
import Node.Process as Process
import Psvm.Ls as Ls


perform :: Array String -> Effect Unit
perform = tailRecM go
  where
    go argv = case Array.uncons argv of
      Just { head, tail }
        | head == "-h" || head == "--help" ->
          Console.log usage *> Process.exit 0

        | otherwise ->
          Console.error usage *> Process.exit 1

      _ -> do
        versions <- Ls.listVersions

        Console.log "Available Versions:"

        for_ versions \version ->
          Console.log ( "    " <> version )

        Process.exit 0


usage :: String
usage = """Usage: psvm ls [-h | --help]

List PureScript versions.
"""
