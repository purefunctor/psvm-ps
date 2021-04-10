module Psvm.Files where

import Prelude

import Data.Array as Array
import Data.Either (hush)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (log)
import Node.Path (FilePath)
import Node.Path as Path
import Psvm.Foreign.Download (downloadUrlTo, extractFromTo)
import Psvm.Shell (spawn, spawn_)
import Psvm.Version (Version)
import Psvm.Version as Version
import Text.Parsing.StringParser (runParser)
import Text.Parsing.StringParser.CodeUnits (char, eof, regex)
import Text.Parsing.StringParser.Combinators (manyTill)


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


getDownloadUrl :: Version -> String
getDownloadUrl version =
  "https://github.com/purescript/purescript/releases/download/"
    <> show version <> "/linux64.tar.gz"


mkdir :: FilePath -> Effect Unit
mkdir path = do
  spawn_ "mkdir" [ "-p", path ]


installPurs :: PsvmFolder -> Version -> Effect Unit
installPurs psvm version = do
  mkdir psvm.archives

  let version' = Version.toString version
      url = getDownloadUrl version
      dnl = Path.concat [ psvm.archives, version' <> ".tar.gz" ]
      ins = Path.concat [ psvm.versions, version' ]

  downloadUrlTo url dnl do
    log $ "Downloaded: " <> version'
    extractFromTo dnl ins do
      log $ "Installed: " <> ins


selectPurs :: PsvmFolder -> Version -> Effect Unit
selectPurs psvm version = do
  mkdir psvm.versions

  spawn_ "cp"
    [ "-f"
    , Path.concat [ psvm.versions, Version.toString version, "purescript", "purs" ]
    , Path.concat [ psvm.current, "bin" ]
    ]


removePurs :: PsvmFolder -> Version -> Effect Unit
removePurs psvm version = do
  spawn_ "rm"
    [ "-r",  Path.concat [ psvm.versions, Version.toString version ]
    ]


cleanPurs :: PsvmFolder -> Effect Unit
cleanPurs psvm = do
  spawn_ "rm"
    [ "-r", Path.concat [ psvm.archives, "**" ]
    ]


listPurs :: PsvmFolder -> Effect ( Array String )
listPurs psvm = do
  mkdir psvm.versions

  let split = manyTill ( regex ".+" <* char '\n' ) eof

  mVersions <- hush <<< runParser split <$>
    spawn "ls" [ "-1", "-X", psvm.versions ]

  case mVersions of
    Nothing ->
      pure [ ]
    Just versions ->
      pure $ Array.fromFoldable versions
