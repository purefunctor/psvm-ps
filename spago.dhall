{ name = "psvm-ps"
, dependencies =
  [ "argonaut-codecs"
  , "console"
  , "effect"
  , "node-child-process"
  , "node-fs"
  , "node-process"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
