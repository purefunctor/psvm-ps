{ name = "psvm-ps"
, dependencies =
  [ "argonaut-codecs"
  , "argparse-basic"
  , "arrays"
  , "console"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "foreign-object"
  , "integers"
  , "maybe"
  , "newtype"
  , "node-buffer"
  , "node-fs"
  , "node-http"
  , "node-path"
  , "node-process"
  , "node-streams"
  , "options"
  , "prelude"
  , "psci-support"
  , "refs"
  , "string-parsers"
  , "tuples"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
