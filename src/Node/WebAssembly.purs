module Node.WebAssembly
  ( instantiate
  , instantiateModule
  , compile
  , validate
  , ResultObject

  , instantiateRaw
  , instantiateModuleRaw
  ) where


import Prelude

import Control.Promise (Promise, toAffE)
import Data.ArrayBuffer.Types (ArrayBuffer)
import Effect (Effect)
import Effect.Aff (Aff)

import Node.WebAssembly.ImportObject
  (ImportObjectRaw, ImportObject, uncookImportObject)
import Node.WebAssembly.Instance (Instance)
import Node.WebAssembly.Module (Module)


foreign import instantiateRawImpl :: ImportObjectRaw -> ArrayBuffer -> Effect (Promise ResultObject)

foreign import instantiateModuleRawImpl :: ImportObjectRaw -> Module -> Effect (Promise Instance)

foreign import compileImpl :: ArrayBuffer -> Effect (Promise Module)

foreign import validate :: ArrayBuffer -> Boolean


type ResultObject =
  { module :: Module
  , instance :: Instance
  }


instantiateRaw :: ImportObjectRaw -> ArrayBuffer -> Aff ResultObject
instantiateRaw imports buf = toAffE $ instantiateRawImpl imports buf


instantiateModuleRaw :: ImportObjectRaw -> Module -> Aff Instance
instantiateModuleRaw imports buf = toAffE $ instantiateModuleRawImpl imports buf


instantiate :: ImportObject -> ArrayBuffer -> Aff ResultObject
instantiate imports = instantiateRaw (uncookImportObject imports)


instantiateModule :: ImportObject -> Module -> Aff Instance
instantiateModule imports = instantiateModuleRaw (uncookImportObject imports)


compile :: ArrayBuffer -> Aff Module
compile buf = toAffE $ compileImpl buf
