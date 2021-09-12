module Psvm.Foreign.Download where

import Data.Unit (Unit)
import Effect (Effect)

type Callback = Effect Unit

foreign import downloadUrlToImpl :: String -> String -> Callback -> Effect Unit

downloadUrlTo :: String -> String -> Callback -> Effect Unit
downloadUrlTo = downloadUrlToImpl

foreign import extractFromToImpl :: String -> String -> Callback -> Effect Unit

extractFromTo :: String -> String -> Callback -> Effect Unit
extractFromTo = extractFromToImpl
