module Psvm.Ls where

import Prelude

import Data.Argonaut.Decode (class DecodeJson, decodeJson, parseJson, (.:))
import Data.Either (Either(..))
import Data.Newtype (class Newtype, unwrap)
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Console as Console
import Node.Process as Process
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
  result <- spawn "curl" [ releaseUrl ]

  case parseJson result >>= decodeJson of
    Left err ->
      Console.errorShow err *> Process.exit 1
    Right releases ->
      pure releases


listVersions :: Effect ( Array String  )
listVersions = getReleases >>= traverse (pure <<< _.tagName <<< unwrap)
