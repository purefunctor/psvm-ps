module Main where

import Prelude

import Control.Monad.Rec.Class (Step(..), tailRecM)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console as Console
import Node.Process as Process
import Psvm.Cli.Global as Global
import Psvm.Cli.Install as Install
import Psvm.Cli.Local as Local
import Psvm.Cli.Ls as Ls
import Psvm.Cli.Rm as Rm


perform :: Array String -> Effect Unit
perform = tailRecM go
  where
    go argv = case Array.uncons argv of
      Just { head, tail }
        | head == "-h" || head == "--help" ->
          Console.log usage *> Process.exit 0

        | head == "-v" || head == "--version" -> do
          Console.log version *> Process.exit 0

        | head == "install" ->
          Done <$> Install.perform tail

        | head == "rm" ->
          Done <$> Rm.perform tail

        | head == "global" ->
          Done <$> Global.perform tail

        | head == "local" ->
          Done <$> Local.perform tail

        | head == "ls" ->
          Done <$> Ls.perform tail

      _ ->
        Console.log usage *> Process.exit 1


main :: Effect Unit
main = do
  cwd <- Process.cwd
  argv <- Array.drop 2 <$> Process.argv
  perform argv


version :: String
version = "psvm-ps - v0.1.0"


usage :: String
usage = """psvm-ps - PureScript version management in PureScript.

Usage: psvm [-h | --help] [-v | --version]
       (install | rm | global | local | ls)

Available Commands:
  install           Install a PureScript version.
  rm                Remove a PureScript version
  global            Set a global PureScript version.
  local             Set a local PureScript version.
  ls                List PureScript versions.
"""
