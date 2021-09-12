module Psvm.Version where

import Prelude

import Data.Array as Array
import Data.Either (hush)
import Data.Int as Int
import Data.Maybe (Maybe)
import Text.Parsing.StringParser (runParser)
import Text.Parsing.StringParser.CodeUnits (char, regex)
import Text.Parsing.StringParser.Combinators (optional)

data Version = Version Int Int Int String

derive instance eqVersion :: Eq Version

instance Ord Version where
  compare (Version major minor patch _) (Version major' minor' patch' _) =
    Array.fold [ compare major major', compare minor minor', compare patch patch' ]

instance Show Version where
  show = toString

fromString :: String -> Maybe Version
fromString = join <<< hush <<< runParser do
  _ <- optional $ char 'v'

  major <- Int.fromString <$> regex "\\d+"

  void $ char '.'

  minor <- Int.fromString <$> regex "\\d+"

  void $ char '.'

  patch <- Int.fromString <$> regex "\\d+"

  extra <- regex ".*"

  pure $ Version <$> major <*> minor <*> patch <*> pure extra

toString :: Version -> String
toString (Version major minor patch extra) = Array.intercalate ""
  [ "v", show major, ".", show minor, ".", show patch, extra ]
