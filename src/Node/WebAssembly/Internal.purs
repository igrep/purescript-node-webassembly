module Node.WebAssembly.Internal where

import Foreign (Foreign)


foreign import isFunc :: Int -> Foreign -> Boolean
foreign import isTable :: Foreign -> Boolean
foreign import isMemory :: Foreign -> Boolean
foreign import isGlobal :: Foreign -> Boolean
foreign import toString :: Foreign -> String
