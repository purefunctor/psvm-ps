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
import Effect.Exception (throw)
import Node.Platform (Platform(..))
import Node.Process as Process
import Psvm.Files (cleanPurs, getPsvmFolder, installPurs, removePurs, selectPurs)
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
      home <- getHome
      let psvm = getPsvmFolder home
      performCommand psvm c
  where
    performCommand psvm =
      case _ of
        Install mv ->
          tryVersion mv \v -> do
            installPurs psvm v

        Uninstall mv ->
          tryVersion mv \v -> do
            removePurs psvm v

        Use mv -> do
          tryVersion mv \v -> do
            selectPurs psvm v

        Ls { remote }
          | remote    -> Ls.printRemote
          | otherwise -> Ls.printLocal psvm

        Clean -> cleanPurs psvm

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

getHome :: Unit -> Effect String
getHome = do
  mHome <-
    case Process.platform of
    Nothing -> Console.error "Process.platform unset"
               throw "Process.platform unset"
               Process.exit 1 :: (Effect (Maybe String))
               -- Process.lookupEnv "HOME"
    Just platform ->
      case platform of
      Linux -> Process.lookupEnv "HOME"
      Darwin -> Process.lookupEnv "HOME" -- Mac
      Win32 -> Process.lookupEnv "USERPROFILE"
      _ -> Process.lookupEnv "HOME"
  case mHome of
    Nothing -> do
      Console.error "Fatal: unset HOME"
      Process.exit 1
    Just home -> pure home

{-----------------------------------------------------------------------}

name :: String
name = "psvm-ps"


version :: String
version = "psvm-ps - v0.2.1"


about :: String
about = "PureScript version management in PureScript."


main :: Effect Unit
main = do
  cwd <- Process.cwd
  argv <- Array.drop 2 <$> Process.argv
  perform argv
