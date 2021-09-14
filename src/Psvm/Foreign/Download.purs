module Psvm.Foreign.Download where

import Data.Unit (Unit)
import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Node.Path (FilePath)
import Psvm.Types (Psvm, exitError, liftCatchAff)

foreign import downloadUrlToP :: String -> String -> Effect (Promise Unit)

downloadUrlTo :: FilePath -> FilePath -> Psvm Unit
downloadUrlTo url to = liftCatchAff (toAffE (downloadUrlToP url to)) (exitError 1)

foreign import extractFromToP :: String -> String -> Effect (Promise Unit)

extractFromTo :: FilePath -> FilePath -> Psvm Unit
extractFromTo from to = liftCatchAff (toAffE (extractFromToP from to)) (exitError 1)
