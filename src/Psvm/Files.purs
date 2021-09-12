module Psvm.Files where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (log)
import Effect.Console as Console
import Node.FS.Async as FS
import Node.Path (FilePath)
import Node.Path as Path
import Node.Platform (Platform(..))
import Node.Process as Process
import Psvm.Foreign.Download (downloadUrlTo, extractFromTo)
import Psvm.Version (Version)
import Psvm.Version as Version


type PsvmFolder =
  { archives :: FilePath
  , current  :: FilePath
  , versions :: FilePath
  }


getPsvmFolder :: FilePath -> PsvmFolder
getPsvmFolder base =
  let
    base' = Path.concat [ base, ".psvm" ]
  in
    { archives : Path.concat [ base', "archives" ]
    , current  : Path.concat [ base', "current"  ]
    , versions : Path.concat [ base', "versions" ]
    }

getPlatformName :: Effect String
getPlatformName =
  case Process.platform of
    Nothing -> do
      Console.error "unknown platform"
      Process.exit 1
    Just platform ->
      case platform of
        Linux -> pure "linux64"
        Darwin -> pure "macos"
        Win32 -> pure "win64"
        _ -> do
          Console.error "unsupported platform"
          Process.exit 1


getDownloadUrl :: Version -> String -> String
getDownloadUrl version platform =
  "https://github.com/purescript/purescript/releases/download/"
    <> show version <> "/" <> platform <> ".tar.gz"


foreign import mkdirRecursive :: String -> Effect Unit -> Effect Unit


installPurs :: PsvmFolder -> Version -> Effect Unit
installPurs psvm version = do
  platform <- getPlatformName

  let version' = Version.toString version
      url = getDownloadUrl version platform
      dnl = Path.concat [ psvm.archives, version' <> ".tar.gz" ]
      ins = Path.concat [ psvm.versions, version' ]

  mkdirRecursive psvm.archives $
    downloadUrlTo url dnl do
      log $ "Downloaded: " <> version'
      extractFromTo dnl ins do
        log $ "Installed: " <> ins


foreign import copyFileImpl :: String -> String -> Effect Unit -> Effect Unit


selectPurs :: PsvmFolder -> Version -> Effect Unit
selectPurs psvm version = do
  let version' = Version.toString version
      src = Path.concat [ psvm.versions, version', "purescript", "purs" ]
      to = Path.concat [ psvm.current, "bin", "purs" ]

  mkdirRecursive psvm.archives $
    copyFileImpl src to do
      Console.log $ "Using PureScript: " <> version'


foreign import rmRecursiveImpl :: String -> Effect Unit -> Effect Unit


removePurs :: PsvmFolder -> Version -> Effect Unit
removePurs psvm version = do
  let version' = Version.toString version
      target = Path.concat [ psvm.versions, version' ]
  rmRecursiveImpl target do
    Console.log $ "Uninstalled PureScript: " <> version'


cleanPurs :: PsvmFolder -> Effect Unit
cleanPurs psvm =
  rmRecursiveImpl psvm.archives do
    Console.log $ "Cleaned artifacts on: " <> psvm.archives


listPurs :: PsvmFolder -> (Array String -> Effect Unit) -> Effect Unit
listPurs psvm cb = do
  mkdirRecursive psvm.archives $
    FS.readdir psvm.versions $
      case _ of
        Left err -> do
          Console.error $ "Fatal error: " <> show err
          Process.exit 1
        Right files ->
          cb files
