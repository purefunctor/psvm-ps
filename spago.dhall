{ name = "psvm-ps"
, dependencies = [ "console", "effect", "psci-support" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
