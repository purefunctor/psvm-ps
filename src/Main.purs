module Main where

import Prelude

import ArgParse.Basic (ArgParser, anyNotFlag, boolean, choose, command, flag, flagHelp, flagInfo, parseArgs, printArgError)
import Data.Array as Array
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Effect (Effect)
import Effect.Console as Console
import Node.Process as Process
import Psvm.Files (cleanPurs, downloadPurs, getPsvmFolder, removePurs, selectPurs, unpackPurs)
import Psvm.Ls as Ls
import Psvm.Version (Version)
import Psvm.Version as Version

{-----------------------------------------------------------------------}

data Command
  = Install (Maybe Version)
  | Uninstall (Maybe Version)
  | Use (Maybe Version)
  | Ls { remote :: Boolean }
  | Clean

derive instance genericCommand :: Generic Command _

instance showCommand :: Show Command where
  show = genericShow


commandParser :: ArgParser Command
commandParser =
  choose "command"
  [ command [ "install" ] "Install a PureScript version." $
      flagHelp *> anyNotFlag "VERSION" "version to install"
        <#> Install <<< Version.fromString

  , command [ "uninstall" ] "Uninstall a PureScript version." $
      flagHelp *> anyNotFlag "VERSION" "version to uninstall"
        <#> Uninstall <<< Version.fromString

  , command [ "use" ] "Use a PureScript version." $
      flagHelp *> anyNotFlag "VERSION" "version to use"
        <#> Use <<< Version.fromString

  , command [ "ls" ] "List PureScript versions." $
      flagHelp *>
        ( flag [ "-r", "--remote" ] "List remote versions." # boolean )
          <#> \remote -> Ls { remote }

  , command [ "clean" ] "Clean downloaded artifacts." $
      flagHelp $> Clean
  ]

{-----------------------------------------------------------------------}

perform :: Array String -> Effect Unit
perform argv =
  case parseArgs name about parser argv of

    Left e ->
      Console.log $ printArgError e

    Right c -> do
      mHome <- Process.lookupEnv "HOME"

      case mHome of
        Nothing -> do
          Console.error "Fatal: unset HOME"
          Process.exit 1
        Just home -> do
          let psvm = getPsvmFolder home
          performCommand psvm c
  where
    performCommand psvm =
      case _ of
        Install mv ->
          tryVersion mv \v -> do
            downloadPurs psvm v
            unpackPurs psvm v
            Console.log $
              "Installed PureScript: " <> Version.toString v

        Uninstall mv ->
          tryVersion mv \v -> do
            removePurs psvm v
            Console.log $
              "Uninstalled PureScript: " <> Version.toString v

        Use mv -> do
          tryVersion mv \v -> do
            selectPurs psvm v
            Console.log $
              "Using PureScript: " <> Version.toString v

        Ls { remote }
          | remote    -> Ls.printRemote
          | otherwise -> Ls.printLocal psvm

        Clean -> do
          cleanPurs psvm
          Console.log $
            "Cleaned artifacts on: " <> psvm.archives

    tryVersion mv cb =
      case mv of
        Nothing -> do
          Console.error "Invalid version"
          Process.exit 1
        Just v -> cb v



parser :: ArgParser Command
parser =
  flagHelp *> versionFlag *> commandParser

  where
    versionFlag =
      flagInfo [ "--version", "-v" ]
        "Show the installed psvm-ps version." version

{-----------------------------------------------------------------------}

name :: String
name = "psvm-ps"


version :: String
version = "psvm-ps - v0.1.2"


about :: String
about = "PureScript version management in PureScript."


main :: Effect Unit
main = do
  cwd <- Process.cwd
  argv <- Array.drop 2 <$> Process.argv
  perform argv
