module Psvm.Files where

import Prelude

import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (makeAff, nonCanceler)
import Effect.Class.Console as Console
import Node.FS.Async as FS
import Node.Path (FilePath)
import Node.Path as Path
import Psvm.Foreign.Download (downloadUrlTo, extractFromTo)
import Psvm.Platform as Platform
import Psvm.Types (Psvm, exitError, liftCatchAff)
import Psvm.Version (Version)
import Run (liftAff)

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

  mkdirRecursive psvm.archives

  downloadUrlTo url dnl
  Console.log $ "Downloaded: " <> vrs

  extractFromTo dnl unp
  Console.log $ "Installed: " <> unp

selectPurs :: Version -> Psvm Unit
selectPurs version = do
  psvm <- askPsvmFolder

  let
    vrs = show version
    src = Path.concat [ psvm.versions, vrs, "purescript", "purs" ]
    to = Path.concat [ psvm.current, "bin", "purs" ]

  mkdirRecursive psvm.archives
  copyFile src to

  Console.log $ "Using PureScript: " <> vrs

removePurs :: Version -> Psvm Unit
removePurs version = do
  psvm <- askPsvmFolder

  let
    vrs = show version
    target = Path.concat [ psvm.versions, vrs ]

  rmRecursive target
  Console.log $ "Uninstalled PureScript: " <> vrs

cleanPurs :: Psvm Unit
cleanPurs = do
  psvm <- askPsvmFolder
  rmRecursive psvm.archives
  Console.log $ "Cleaned artifacts on: " <> psvm.archives

listPurs :: PsvmFolder -> Psvm (Array String)
listPurs psvm = do
  mkdirRecursive psvm.archives
  readDir psvm.versions
  where
  readDir dir = liftAff $ makeAff \n -> FS.readdir dir n $> nonCanceler


foreign import copyFileP :: String -> String -> Effect (Promise Unit)

copyFile :: FilePath -> FilePath -> Psvm Unit
copyFile from to = liftCatchAff (toAffE (copyFileP from to)) (exitError 1)

foreign import rmRecursiveP :: String -> Effect (Promise Unit)

rmRecursive :: FilePath -> Psvm Unit
rmRecursive dir = liftCatchAff (toAffE (rmRecursiveP dir)) (exitError 1)

foreign import mkdirRecursiveP :: String -> Effect (Promise Unit)

mkdirRecursive :: FilePath -> Psvm Unit
mkdirRecursive dir = liftCatchAff (toAffE (mkdirRecursiveP dir)) (exitError 1)
