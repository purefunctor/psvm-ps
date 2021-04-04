module Main where

import Prelude

import ArgParse.Basic (ArgParser, anyNotFlag, boolean, choose, command, flag, flagHelp, flagInfo, parseArgs, printArgError)
import Data.Array as Array
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Effect (Effect)
import Effect.Console as Console
import Node.Process as Process
import Psvm.Ls as Ls

{-----------------------------------------------------------------------}

type Version = String


data Command
  = Install Version
  | Uninstall Version
  | Use Version
  | Ls { remote :: Boolean }

derive instance genericCommand :: Generic Command _

instance showCommand :: Show Command where
  show = genericShow


commandParser :: ArgParser Command
commandParser =
  choose "command"
  [ command [ "install" ] "Install a PureScript version." $
      flagHelp *> anyNotFlag "VERSION" "version to install"
        <#> Install

  , command [ "uninstall" ] "Uninstall a PureScript version." $
      flagHelp *> anyNotFlag "VERSION" "version to uninstall"
        <#> Uninstall

  , command [ "use" ] "Use a PureScript version." $
      flagHelp *> anyNotFlag "VERSION" "version to use"
        <#> Use

  , command [ "ls" ] "List PureScript versions." $
      flagHelp *>
        ( flag [ "-r", "--remote" ] "List remote versions?" # boolean )
          <#> \remote -> Ls { remote }
  ]

{-----------------------------------------------------------------------}

perform :: Array String -> Effect Unit
perform argv =
  case parseArgs name about parser argv of

    Left e ->
      Console.log $ printArgError e

    Right c ->
      performCommand c

  where
    performCommand = case _ of
      Ls { remote }
        | remote    -> Ls.printRemote
        | otherwise -> Ls.printLocal

      c ->
        Console.logShow c *> Process.exit 0


parser :: ArgParser Command
parser =
  flagHelp *> versionFlag *> commandParser

  where
    versionFlag =
      flagInfo [ "-v", "--versions" ]
        "Show the installed psvm-ps version." version

{-----------------------------------------------------------------------}

name :: String
name = "psvm-ps"


version :: String
version = "psvm-ps - v0.1.0"


about :: String
about = "PureScript version management in PureScript."


main :: Effect Unit
main = do
  cwd <- Process.cwd
  argv <- Array.drop 2 <$> Process.argv
  perform argv
