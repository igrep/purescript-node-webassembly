-- | Example application to run a WASI executable.
module Main where

import Prelude (Unit, bind, discard, ($), (<<<), (=<<), (<>))

import Data.Array ((!!))
import Data.Functor (map)
import Data.Maybe (Maybe (Just, Nothing))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Console (log, error)
import Effect.Class (liftEffect)
import Node.Buffer as Buffer
import Node.FS.Aff as FS
import Node.Process (argv, exit)

import Node.WASI as WASI
import Node.WebAssembly as WebAssembly

main :: Effect Unit
main = do
  marg <- map (_ !! 2) argv
  case marg of
      Just arg -> launchAff_ do
        let wasi = WASI.new WASI.defaultNewOptions
            imports = WASI.wasiImportSnapshotPreview1 wasi
        buf <- liftEffect <<< Buffer.toArrayBuffer =<< FS.readFile arg
        wasm <- WebAssembly.instantiateRaw imports buf
        liftEffect $ WASI.start wasi wasm.instance
        liftEffect $ log $ "Successfully run " <> arg <> "."
      Nothing -> do
        error "No wasm file given!"
        exit 1
