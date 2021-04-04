{ name = "psvm-ps"
, dependencies =
  [ "argonaut-codecs"
  , "argparse-basic"
  , "console"
  , "effect"
  , "node-child-process"
  , "node-fs"
  , "node-path"
  , "node-process"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
