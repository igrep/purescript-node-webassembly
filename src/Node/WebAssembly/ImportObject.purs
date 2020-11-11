-- | Common types and functions related to objects which can be
-- | imported from WebAssembly to JavaScript.
module Node.WebAssembly.ImportObject
  ( ImportObject
  , Importable (..)

  , ImportObjectRaw

  , uncookImportObject
  , cookImportObject
  , toImportObjectRaw
  ) where


import Prelude (($), otherwise)

import Data.Functor (map)
import Data.Monoid ((<>))
import Effect (Effect)
import Effect.Exception.Unsafe (unsafeThrow)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, EffectFn4, EffectFn5, EffectFn6, EffectFn7, EffectFn8, EffectFn9, EffectFn10)
import Foreign (Foreign, unsafeToForeign, unsafeFromForeign)
import Foreign.Object (Object)

import Node.WebAssembly.Global (Global)
import Node.WebAssembly.Internal (isFunc, isTable, isMemory, isGlobal, toString)
import Node.WebAssembly.Memory (Memory)
import Node.WebAssembly.Table (Table, Anyfunc)


type ImportObject = Object (Object Importable)

newtype ImportObjectRaw = ImportObjectRaw (Object (Object Foreign))


toImportObjectRaw :: Partial => Object (Object Foreign) -> ImportObjectRaw
toImportObjectRaw = ImportObjectRaw


-- | Objects which can be imported to WebAssembly module from JavaScript.
data Importable =
    Func0 (Effect Foreign)
  | Func1 (EffectFn1 Foreign Foreign)
  | Func2 (EffectFn2 Foreign Foreign Foreign)
  | Func3 (EffectFn3 Foreign Foreign Foreign Foreign)
  | Func4 (EffectFn4 Foreign Foreign Foreign Foreign Foreign)
  | Func5 (EffectFn5 Foreign Foreign Foreign Foreign Foreign Foreign)
  | Func6 (EffectFn6 Foreign Foreign Foreign Foreign Foreign Foreign Foreign)
  | Func7 (EffectFn7 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign)
  | Func8 (EffectFn8 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign)
  | Func9 (EffectFn9 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign)
  | Func10 (EffectFn10 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign)
  | TableAnyfunc (Table Anyfunc)
  | Memory Memory
  | Global Global


uncookImportObject :: ImportObject -> ImportObjectRaw
uncookImportObject imports = ImportObjectRaw $ map (map toForeign) imports


cookImportObject :: ImportObjectRaw -> ImportObject
cookImportObject (ImportObjectRaw imports) = map (map fromForeign) imports


toForeign :: Importable -> Foreign
toForeign (Func0 fn0) = unsafeToForeign fn0
toForeign (Func1 fn1) = unsafeToForeign fn1
toForeign (Func2 fn2) = unsafeToForeign fn2
toForeign (Func3 fn3) = unsafeToForeign fn3
toForeign (Func4 fn4) = unsafeToForeign fn4
toForeign (Func5 fn5) = unsafeToForeign fn5
toForeign (Func6 fn6) = unsafeToForeign fn6
toForeign (Func7 fn7) = unsafeToForeign fn7
toForeign (Func8 fn8) = unsafeToForeign fn8
toForeign (Func9 fn9) = unsafeToForeign fn9
toForeign (Func10 fn10) = unsafeToForeign fn10
toForeign (TableAnyfunc table) = unsafeToForeign table
toForeign (Memory memory) = unsafeToForeign memory
toForeign (Global global) = unsafeToForeign global


-- | Keep this internal because this is implicitly Partial.
fromForeign :: Foreign -> Importable
fromForeign value
  | isFunc 0 value = Func0 $ unsafeFromForeign value
  | isFunc 1 value = Func1 $ unsafeFromForeign value
  | isFunc 2 value = Func2 $ unsafeFromForeign value
  | isFunc 3 value = Func3 $ unsafeFromForeign value
  | isFunc 4 value = Func4 $ unsafeFromForeign value
  | isFunc 5 value = Func5 $ unsafeFromForeign value
  | isFunc 6 value = Func6 $ unsafeFromForeign value
  | isFunc 7 value = Func7 $ unsafeFromForeign value
  | isFunc 8 value = Func8 $ unsafeFromForeign value
  | isFunc 9 value = Func9 $ unsafeFromForeign value
  | isFunc 10 value = Func10 $ unsafeFromForeign value
  | isTable value = TableAnyfunc $ unsafeFromForeign value
  | isMemory value = Memory $ unsafeFromForeign value
  | isGlobal value = Global $ unsafeFromForeign value
  | otherwise = unsafeThrow $ "Assertion failure: Unknown imported/exported object: " <> toString value
