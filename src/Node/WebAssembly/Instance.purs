module Node.WebAssembly.Instance
  ( new
  , Instance
  , exports

  , newRaw
  , exportsRaw
  ) where

import Prelude (($))

import Effect (Effect)
import Node.WebAssembly.Exports (Exports, ExportsRaw, cookExports)
import Node.WebAssembly.ImportObject (ImportObjectRaw, ImportObject, uncookImportObject)
import Node.WebAssembly.Module (Module)


foreign import data Instance :: Type

-- | Returns an Effect because the constructor of WebAssembly.Instance can
-- | implicitly alter the instance of WebAssembly.Table passed via the
-- | import object.
foreign import newRaw :: ImportObjectRaw -> Module -> Effect Instance

foreign import exportsRaw :: Instance -> ExportsRaw


-- | Returns an Effect because the constructor of WebAssembly.Instance can
-- | implicitly alter the instance of WebAssembly.Table passed via the
-- | import object.
new :: ImportObject -> Module -> Effect Instance
new imp mod = newRaw (uncookImportObject imp) mod


exports :: Instance -> Exports
exports inst = cookExports $ exportsRaw inst
