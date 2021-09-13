module Main where

import Prelude

import ArgParse.Basic (ArgParser, anyNotFlag, boolean, choose, command, flag, flagHelp, flagInfo, parseArgs, printArgError)
import Data.Array as Array
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Node.Process as Process
import Psvm.Files as Files
import Psvm.Ls as Ls
import Psvm.Types (Psvm, exit, runPsvm)
import Psvm.Version (Version)
import Psvm.Version as Version

data Command
  = Install (Maybe Version)
  | Uninstall (Maybe Version)
  | Use (Maybe Version)
  | Ls { remote :: Boolean }
  | Clean

derive instance Eq Command
derive instance Generic Command _

instance Show Command where
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
          (flag [ "-r", "--remote" ] "List remote versions." # boolean)
          <#> \remote -> Ls { remote }

    , command [ "clean" ] "Clean downloaded artifacts." $
        flagHelp $> Clean
    ]

main :: String -> String -> String -> Effect Unit
main name version about = do
  argv <- Array.drop 2 <$> Process.argv
  launchAff_$
    runPsvm {} (perform argv)
  where
  perform :: Array String -> Psvm Unit
  perform argv =
    case parseArgs name about parser argv of
      Left e ->
        exit 1 (printArgError e)
      Right c ->
        case c of
          Install v ->
            tryVersion v Files.installPurs

          Uninstall v ->
            tryVersion v Files.removePurs

          Use v -> do
            tryVersion v Files.selectPurs

          Ls { remote }
            | remote -> Ls.printRemote
            | otherwise -> Ls.printLocal

          Clean -> Files.cleanPurs
    where
    parser :: ArgParser Command
    parser = flagHelp *> versionFlag *> commandParser
      where
      versionFlag =
        flagInfo [ "--version", "-v" ] "Show the installed psvm-ps version." version

    tryVersion :: Maybe Version -> (Version -> Psvm Unit) -> Psvm Unit
    tryVersion v command =
      case v of
        Nothing -> exit 1 "Invalid version"
        Just v' -> command v'
