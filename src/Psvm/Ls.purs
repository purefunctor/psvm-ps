module Psvm.Ls where

import Prelude

import Data.Argonaut.Decode (class DecodeJson, decodeJson, parseJson, (.:))
import Data.Either (Either(..))
import Data.Newtype (class Newtype, unwrap)
import Data.Options ((:=))
import Data.Traversable (for_)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Console as Console
import Effect.Ref as Ref
import Foreign.Object (fromFoldable)
import Node.Encoding as Encoding
import Node.HTTP.Client as Client
import Node.Process as Process
import Node.Stream (end, onDataString, onEnd)
import Psvm.Files (PsvmFolder, listPurs)


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


getReleases :: ( Array ReleaseJson -> Effect Unit ) -> Effect Unit
getReleases cb = do
  let headers_ = Client.RequestHeaders $ fromFoldable
        [ Tuple "User-Agent" "psvm-ps"
        ]

      options =
        Client.headers := headers_ <>
        Client.hostname := "api.github.com" <>
        Client.path := "/repos/purescript/purescript/releases" <>
        Client.method := "GET" <>
        Client.protocol := "https:" <>
        Client.port := 443

  req <- Client.request options \response -> do
    let stream = Client.responseAsStream response

    buffer <- Ref.new ""

    onDataString stream Encoding.UTF8 \chunk -> do
      Ref.modify_ (_ <> chunk) buffer

    onEnd stream do
      result <- Ref.read buffer
      case parseJson result >>= decodeJson of
        Left err ->
          Console.errorShow err *> Process.exit 1
        Right releases -> do
          cb releases

  end (Client.requestAsStream req) (pure unit)


printRemote :: Effect Unit
printRemote = do
  getReleases \versions -> do
    Console.log "Available PureScript Versions:"
    for_ versions \version ->
      Console.log ( "    " <> (unwrap version).tagName )


printLocal :: PsvmFolder -> Effect Unit
printLocal psvm = do
  listPurs psvm \versions -> do
    Console.log "Available PureScript Versions:"
    for_ versions \version ->
      Console.log ( "    " <> version )
