module Psvm.Shell where

import Prelude

import Data.Array (intercalate)
import Effect (Effect)
import Node.Buffer (toString)
import Node.ChildProcess as Child
import Node.Encoding as Encoding


spawn_ :: String -> Array String -> Effect Unit
spawn_ command arguments = do
  let cmd = intercalate " " [ command, ( intercalate " " arguments ) ]

  void $ Child.execSync cmd Child.defaultExecSyncOptions { stdio = stdio }

  where
    stdio = Child.inherit


spawn :: String -> Array String -> Effect String
spawn command arguments = do
  let cmd = intercalate " " [ command, ( intercalate " " arguments ) ]

  stdout <- Child.execSync cmd Child.defaultExecSyncOptions { stdio = stdio }

  toString Encoding.UTF8 stdout

  where
    stdio = Child.pipe
