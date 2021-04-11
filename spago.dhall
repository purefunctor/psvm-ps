{ name = "psvm-ps"
, dependencies =
  [ "argonaut-codecs"
  , "argparse-basic"
  , "arrays"
  , "console"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "integers"
  , "maybe"
  , "newtype"
  , "node-buffer"
  , "node-child-process"
  , "node-fs"
  , "node-path"
  , "node-process"
  , "prelude"
  , "psci-support"
  , "string-parsers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
