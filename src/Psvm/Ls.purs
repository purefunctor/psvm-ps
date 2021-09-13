module Psvm.Ls where

import Prelude

import Data.Argonaut.Decode (class DecodeJson, decodeJson, parseJson, printJsonDecodeError, (.:))
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Data.Newtype (class Newtype, unwrap)
import Data.Options ((:=))
import Data.Traversable (for_)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, error, makeAff, nonCanceler)
import Effect.Class.Console as Console
import Effect.Exception (Error)
import Effect.Ref as Ref
import Foreign.Object (fromFoldable)
import Node.Encoding as Encoding
import Node.HTTP.Client as Client
import Node.Stream (end, onDataString, onEnd)
import Psvm.Files (askPsvmFolder, listPurs)
import Psvm.Types (Psvm, exitError, liftCatchAff)

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

getReleases :: Psvm (Array ReleaseJson)
getReleases = liftCatchAff affGo (exitError 1)
  where
  affGo :: Aff (Array ReleaseJson)
  affGo = makeAff \n -> go n $> nonCanceler

  go :: (Either Error (Array ReleaseJson) -> Effect Unit) -> Effect Unit
  go callback = do
    let
      headers_ = Client.RequestHeaders $ fromFoldable
        [ Tuple "User-Agent" "psvm-ps"
        ]

      options =
        Client.headers := headers_
          <> Client.hostname := "api.github.com"
          <> Client.path := "/repos/purescript/purescript/releases"
          <> Client.method := "GET"
          <> Client.protocol := "https:"
          <>
            Client.port := 443

    req <- Client.request options \response -> do
      let stream = Client.responseAsStream response

      buffer <- Ref.new ""

      onDataString stream Encoding.UTF8 \chunk -> do
        Ref.modify_ (_ <> chunk) buffer

      onEnd stream do
        result <- Ref.read buffer
        callback (lmap (error <<< printJsonDecodeError) $ parseJson result >>= decodeJson)

    end (Client.requestAsStream req) (pure unit)

printRemote :: Psvm Unit
printRemote = do
  versions <- getReleases
  Console.log "Available PureScript Versions:"
  for_ versions \version -> do
    Console.log ("    " <> (unwrap version).tagName)

printLocal :: Psvm Unit
printLocal = do
  psvm <- askPsvmFolder
  versions <- listPurs psvm
  Console.log "Available PureScript Versions:"
  for_ versions \version ->
    Console.log ("    " <> version)
