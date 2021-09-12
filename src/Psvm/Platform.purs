-- | Platform-related actions.
module Psvm.Platform where

import Prelude

import Data.Maybe (Maybe(..))
import Node.Platform as Platform
import Node.Process as Process
import Psvm.Types (Psvm, exit)
import Run (liftEffect)

-- | Supported platforms.
data SupportedPlatform
  = Darwin
  | Linux
  | Win32

derive instance Eq SupportedPlatform

instance Show SupportedPlatform where
  show Darwin = "Darwin"
  show Linux = "Linux"
  show Win32 = "Win32"

platform :: Maybe SupportedPlatform
platform =
  case Process.platform of
    Just platform' ->
      case platform' of
        Platform.Darwin -> Just Darwin
        Platform.Linux -> Just Linux
        Platform.Win32 -> Just Win32
        _ -> Nothing
    _ -> Nothing

releaseName :: SupportedPlatform -> String
releaseName = case _ of
  Darwin -> "macos"
  Linux -> "linux64"
  Win32 -> "win32"

-- | Get the current platform.
askPlatform :: Psvm SupportedPlatform
askPlatform = do
  case platform of
    Nothing -> exit 1 "unknown platform"
    Just platform' -> pure platform'

-- | Get the platform string for release URLs.
askReleaseName :: Psvm String
askReleaseName = releaseName <$> askPlatform

-- | Get the home directory for the current platform.
askHome :: Psvm String
askHome = do
  platform' <- askPlatform
  home <- liftEffect $ case platform' of
    Darwin -> Process.lookupEnv "HOME"
    Linux -> Process.lookupEnv "HOME"
    Win32 -> Process.lookupEnv "USERPROFILE"
  case home of
    Nothing ->
      exit 1 "could not determine home directory from environment variables"
    Just home' ->
      pure home'
