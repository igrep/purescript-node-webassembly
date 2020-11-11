-- | Common types and functions related to objects which can be
-- | exported and imported between WebAssembly and JavaScript.
module Node.WebAssembly.Exports
  ( Exports
  , Exportable (..)

  , ExportsRaw

  , cookExports
  , toExportsRaw

  , getFunc0
  , getFunc1
  , getFunc2
  , getFunc3
  , getFunc4
  , getFunc5
  , getFunc6
  , getFunc7
  , getFunc8
  , getFunc9
  , getFunc10
  , getTableAnyfunc
  , getMemory
  , getGlobal
  ) where


import Prelude (($), otherwise)

import Data.Functor (map)
import Data.Maybe (Maybe (Just, Nothing))
import Data.Monoid ((<>))
import Effect (Effect)
import Effect.Exception.Unsafe (unsafeThrow)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, EffectFn4, EffectFn5, EffectFn6, EffectFn7, EffectFn8, EffectFn9, EffectFn10)
import Foreign (Foreign, unsafeFromForeign)
import Foreign.Object as Object
import Foreign.Object (Object)

import Node.WebAssembly.Global (Global)
import Node.WebAssembly.Internal (isFunc, isTable, isMemory, isGlobal, toString)
import Node.WebAssembly.Memory (Memory)
import Node.WebAssembly.Table (Table, Anyfunc, WasmValue)

type Exports = Object Exportable

newtype ExportsRaw = ExportsRaw (Object Foreign)


toExportsRaw :: Partial => Object Foreign -> ExportsRaw
toExportsRaw = ExportsRaw


-- | Objects which can be exported from WebAssembly module to JavaScript.
data Exportable =
    Func0 (WasmValue (Effect Foreign))
  | Func1 (WasmValue (EffectFn1 Foreign Foreign))
  | Func2 (WasmValue (EffectFn2 Foreign Foreign Foreign))
  | Func3 (WasmValue (EffectFn3 Foreign Foreign Foreign Foreign))
  | Func4 (WasmValue (EffectFn4 Foreign Foreign Foreign Foreign Foreign))
  | Func5 (WasmValue (EffectFn5 Foreign Foreign Foreign Foreign Foreign Foreign))
  | Func6 (WasmValue (EffectFn6 Foreign Foreign Foreign Foreign Foreign Foreign Foreign))
  | Func7 (WasmValue (EffectFn7 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign))
  | Func8 (WasmValue (EffectFn8 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign))
  | Func9 (WasmValue (EffectFn9 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign))
  | Func10 (WasmValue (EffectFn10 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign))
  | TableAnyfunc (Table Anyfunc)
  | Memory Memory
  | Global Global


getFunc0 :: String -> Exports -> Maybe (WasmValue (Effect Foreign))
getFunc0 name exports =
  case Object.lookup name exports of
      Just (Func0 eff) -> Just eff
      _ -> Nothing

getFunc1 :: String -> Exports -> Maybe (WasmValue (EffectFn1 Foreign Foreign))
getFunc1 name exports =
  case Object.lookup name exports of
      Just (Func1 eff) -> Just eff
      _ -> Nothing

getFunc2 :: String -> Exports -> Maybe (WasmValue (EffectFn2 Foreign Foreign Foreign))
getFunc2 name exports =
  case Object.lookup name exports of
      Just (Func2 eff) -> Just eff
      _ -> Nothing

getFunc3 :: String -> Exports -> Maybe (WasmValue (EffectFn3 Foreign Foreign Foreign Foreign))
getFunc3 name exports =
  case Object.lookup name exports of
      Just (Func3 eff) -> Just eff
      _ -> Nothing

getFunc4 :: String -> Exports -> Maybe (WasmValue (EffectFn4 Foreign Foreign Foreign Foreign Foreign))
getFunc4 name exports =
  case Object.lookup name exports of
      Just (Func4 eff) -> Just eff
      _ -> Nothing

getFunc5 :: String -> Exports -> Maybe (WasmValue (EffectFn5 Foreign Foreign Foreign Foreign Foreign Foreign))
getFunc5 name exports =
  case Object.lookup name exports of
      Just (Func5 eff) -> Just eff
      _ -> Nothing

getFunc6 :: String -> Exports -> Maybe (WasmValue (EffectFn6 Foreign Foreign Foreign Foreign Foreign Foreign Foreign))
getFunc6 name exports =
  case Object.lookup name exports of
      Just (Func6 eff) -> Just eff
      _ -> Nothing

getFunc7 :: String -> Exports -> Maybe (WasmValue (EffectFn7 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign))
getFunc7 name exports =
  case Object.lookup name exports of
      Just (Func7 eff) -> Just eff
      _ -> Nothing

getFunc8 :: String -> Exports -> Maybe (WasmValue (EffectFn8 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign))
getFunc8 name exports =
  case Object.lookup name exports of
      Just (Func8 eff) -> Just eff
      _ -> Nothing

getFunc9 :: String -> Exports -> Maybe (WasmValue (EffectFn9 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign))
getFunc9 name exports =
  case Object.lookup name exports of
      Just (Func9 eff) -> Just eff
      _ -> Nothing

getFunc10 :: String -> Exports -> Maybe (WasmValue (EffectFn10 Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign Foreign))
getFunc10 name exports =
  case Object.lookup name exports of
      Just (Func10 eff) -> Just eff
      _ -> Nothing

getTableAnyfunc :: String -> Exports -> Maybe (Table Anyfunc)
getTableAnyfunc name exports =
  case Object.lookup name exports of
      Just (TableAnyfunc tbl) -> Just tbl
      _ -> Nothing

getMemory :: String -> Exports -> Maybe Memory
getMemory name exports =
  case Object.lookup name exports of
      Just (Memory mem) -> Just mem
      _ -> Nothing

getGlobal :: String -> Exports -> Maybe Global
getGlobal name exports =
  case Object.lookup name exports of
      Just (Global glbl) -> Just glbl
      _ -> Nothing


cookExports :: ExportsRaw -> Exports
cookExports (ExportsRaw exports) = map fromForeign exports


-- | Keep this internal because this is implicitly Partial.
fromForeign :: Foreign -> Exportable
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
  | otherwise = unsafeThrow $ "Assertion failure: Unknown exported object: " <> toString value
