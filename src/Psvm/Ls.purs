module Psvm.Ls where

import Prelude

import Data.Argonaut.Decode (class DecodeJson, decodeJson, parseJson, (.:))
import Data.Either (Either(..))
import Data.Newtype (class Newtype, unwrap)
import Data.Traversable (for_, traverse)
import Effect (Effect)
import Effect.Console as Console
import Node.Process as Process
import Psvm.Files (PsvmFolder, listPurs)
import Psvm.Shell (spawn)


releaseUrl :: String
releaseUrl = "https://api.github.com/repos/purescript/purescript/releases"


newtype ReleaseJson = ReleaseJson
  { tagName :: String
  , assetsUrl :: String
  }

derive instance newtypeReleaseJson :: Newtype ReleaseJson _
derive newtype instance showReleaseJson :: Show ReleaseJson


instance decodeJsonRleaseJson :: DecodeJson ReleaseJson where
  decodeJson json = do
    obj <- decodeJson json

    tagName <- obj .: "tag_name"
    assetsUrl <- obj .: "assets_url"

    pure $ ReleaseJson { tagName, assetsUrl }


getReleases :: Effect ( Array ReleaseJson )
getReleases = do
  result <- spawn "curl" [ "-s", releaseUrl ]
  case parseJson result >>= decodeJson of
    Left err ->
      Console.errorShow err *> Process.exit 1
    Right releases ->
      pure releases


listRemote :: Effect ( Array String  )
listRemote = getReleases >>= traverse (pure <<< _.tagName <<< unwrap)


printRemote :: Effect Unit
printRemote = do
  versions <- getReleases

  Console.log "Available PureScript Versions:"

  for_ versions \version ->
    Console.log ( "    " <> (unwrap version).tagName )


printLocal :: PsvmFolder -> Effect Unit
printLocal psvm = do
  listPurs psvm \versions -> do
    Console.log "Available PureScript Versions:"
    for_ versions \version ->
      Console.log ( "    " <> version )
