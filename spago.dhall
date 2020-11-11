{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "purescript-node-webassembly"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "arraybuffer-class"
  , "arraybuffer-types"
  , "bifunctors"
  , "console"
  , "debuggest"
  , "effect"
  , "either"
  , "exceptions"
  , "foreign"
  , "foreign-object"
  , "maybe"
  , "newtype"
  , "node-buffer"
  , "node-fs-aff"
  , "node-process"
  , "partial"
  , "proxy"
  , "psci-support"
  , "record"
  , "spec"
  , "transformers"
  , "tuples"
  , "uint"
  , "unfoldable"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
