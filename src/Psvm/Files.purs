module Psvm.Files where

import Prelude

import Effect (Effect)
import Node.Path (FilePath)
import Node.Path as Path
import Psvm.Shell (spawn)


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


getDownloadUrl :: String -> String
getDownloadUrl version =
  "https://github.com/purescript/purescript/releases/download/"
    <> version <> "/linux64.tar.gz"


-- | Todo: Version Checks, use Node
downloadPurs :: PsvmFolder -> String -> Effect Unit
downloadPurs folder version = do
  void $ spawn "mkdir"
    [ "-p", Path.concat [ folder.archives, version ]
    ]

  void $ spawn "curl"
    [ "-L", getDownloadUrl version
    , "-o", Path.concat [ folder.archives, version <> ".tar.gz" ]
    ]


-- | Todo: Version Checks, use Node
unpackPurs :: PsvmFolder -> String -> Effect Unit
unpackPurs folder version = do
  void $ spawn "mkdir"
    [ "-p", Path.concat [ folder.versions, version ]
    ]

  void $ spawn "tar"
    [ "-xvf", Path.concat [ folder.archives, version <> ".tar.gz" ]
    , "-C", Path.concat [ folder.versions, version ]
    ]


-- | Todo: Version Checks, use Node
selectPurs :: PsvmFolder -> String -> Effect Unit
selectPurs folder version = do
  void $ spawn "mkdir"
    [ "-p", Path.concat [ folder.current, "bin" ]
    ]

  void $ spawn "cp"
    [ "-f"
    , Path.concat [ folder.versions, version, "purescript", "purs" ]
    , Path.concat [ folder.current, "bin" ]
    ]
