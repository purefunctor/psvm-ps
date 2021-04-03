{ name = "psvm-ps"
, dependencies =
  [ "console"
  , "effect"
  , "node-child-process"
  , "node-fs"
  , "node-process"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
