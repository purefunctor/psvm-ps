let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.7-20230127/packages.dhall
        sha256:e0063f83308aa72cffe25444fe86fb484341496c099e38b64574cc7440768fdd

in  upstream
  with argparse-basic =
    { dependencies =
      [ "arrays"
      , "console"
      , "effect"
      , "either"
      , "foldable-traversable"
      , "free"
      , "lists"
      , "maybe"
      , "node-process"
      , "record"
      , "strings"
      , "transformers"
      ]
    , repo = "https://github.com/natefaubion/purescript-argparse-basic.git"
    , version = "v1.0.0"
    }
