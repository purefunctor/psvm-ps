module Psvm.Files where

import Prelude

import Data.Either (Either(..))
import Effect (Effect)
import Effect.Console (log)
import Effect.Console as Console
import Node.FS.Async as FS
import Node.Path (FilePath)
import Node.Path as Path
import Node.Process as Process
import Psvm.Foreign.Download (downloadUrlTo, extractFromTo)
import Psvm.Platform as Platform
import Psvm.Types (Psvm)
import Psvm.Version (Version)
import Run (liftEffect)

type PsvmFolder =
  { archives :: FilePath
  , current :: FilePath
  , versions :: FilePath
  }

askPsvmFolder :: Psvm PsvmFolder
askPsvmFolder = do
  home <- Platform.askHome
  let base = Path.concat [ home, ".psvm" ]
  pure
    { archives: Path.concat [ base, "archives" ]
    , current: Path.concat [ base, "current" ]
    , versions: Path.concat [ base, "versions" ]
    }

askDownloadUrl :: Version -> Psvm String
askDownloadUrl version = do
  platform <- Platform.askReleaseName
  pure $ "https://github.com/purescript/purescript/releases/download/"
    <> show version
    <> "/"
    <> platform
    <> ".tar.gz"

installPurs :: Version -> Psvm Unit
installPurs version = do
  psvm <- askPsvmFolder
  url <- askDownloadUrl version

  let
    vrs = show version
    dnl = Path.concat [ psvm.archives, vrs <> ".tar.gz" ]
    unp = Path.concat [ psvm.versions, vrs ]

  liftEffect $ mkdirRecursive psvm.archives $
    downloadUrlTo url dnl do
      log $ "Downloaded: " <> vrs
      extractFromTo dnl unp do
        log $ "Installed: " <> unp

selectPurs :: Version -> Psvm Unit
selectPurs version = do
  psvm <- askPsvmFolder

  let
    vrs = show version
    src = Path.concat [ psvm.versions, vrs, "purescript", "purs" ]
    to = Path.concat [ psvm.current, "bin", "purs" ]

  liftEffect $ mkdirRecursive psvm.archives $
    copyFile src to do
      Console.log $ "Using PureScript: " <> vrs

removePurs :: Version -> Psvm Unit
removePurs version = do
  psvm <- askPsvmFolder

  let
    vrs = show version
    target = Path.concat [ psvm.versions, vrs ]

  liftEffect $ rmRecursive target do
    Console.log $ "Uninstalled PureScript: " <> vrs

cleanPurs :: Psvm Unit
cleanPurs = do
  psvm <- askPsvmFolder

  liftEffect $ rmRecursive psvm.archives do
    Console.log $ "Cleaned artifacts on: " <> psvm.archives

listPurs :: PsvmFolder -> (Array String -> Effect Unit) -> Psvm Unit
listPurs psvm cb = do
  liftEffect $ mkdirRecursive psvm.archives
    $ FS.readdir psvm.versions
    $
      case _ of
        Left err -> do
          Console.error $ "Fatal error: " <> show err
          Process.exit 1
        Right files ->
          cb files

foreign import mkdirRecursive :: String -> Effect Unit -> Effect Unit

foreign import copyFile :: String -> String -> Effect Unit -> Effect Unit

foreign import rmRecursive :: String -> Effect Unit -> Effect Unit
