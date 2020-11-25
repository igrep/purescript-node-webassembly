-- | Ref. <https://webassembly.github.io/spec/js-api/#tables>

module Node.WebAssembly.Table
  ( Table
  , new
  , newWithMaximum
  , TableDescriptor
  , TableDescriptorRaw
  , kind TableKind
  , class STableKind
  , asRawTableKind
  , Anyfunc
  , class TableElem

  , WasmValue
  , toWasmValue
  , unWasmValue

  , length
  , get
  , set
  , grow

  , getRaw
  , setRaw
  , newRaw
  , newWithMaximumRaw
  , TableKindRaw
  ) where

import Prelude (Unit, ($))

import Data.Functor (map)
import Data.Maybe (Maybe (Just, Nothing), maybe)
import Data.Symbol (SProxy (SProxy))
import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, EffectFn4, EffectFn5, EffectFn6, EffectFn7, EffectFn8, EffectFn9, EffectFn10)
import Foreign (Foreign, unsafeFromForeign, unsafeToForeign)
import Record as Record
import Type.Proxy (Proxy (Proxy))


foreign import data Table :: TableKind -> Type

foreign import kind TableKind

foreign import data Anyfunc :: TableKind


foreign import newRaw :: forall k. { element :: TableKindRaw, initial :: Int } -> Effect (Table k)

foreign import newWithMaximumRaw :: forall k. TableDescriptorRaw -> Effect (Table k)

foreign import grow :: forall k. Int -> Table k -> Effect Int

foreign import getRaw :: forall k. Maybe Foreign -> (Foreign -> Maybe Foreign) -> Int -> Table k -> Effect (Maybe Foreign)

foreign import setRaw :: forall k. Int -> Table k -> Foreign -> Effect Unit

foreign import length :: forall k. Table k -> Effect Int


-- Internal utility
foreign import undefined :: Foreign


type TableKindRaw = String

type TableDescriptorRaw =
  { element :: TableKindRaw
  , initial :: Int
  , maximum :: Int
  }

type TableDescriptor =
  { initial :: Int
  , maximum :: Int
  }

class STableKind a where
  asRawTableKind :: Proxy a -> TableKindRaw

instance anyfuncSTableKind :: STableKind (Table Anyfunc) where
  asRawTableKind _ = "anyfunc"


-- | Reporesents a fact that the wrapped value comes from a Wasm module.
-- | This precondition must be satisified to be an element of a 'Table'.
newtype WasmValue a = WasmValue a

toWasmValue :: forall a. Partial => a -> WasmValue a
toWasmValue = WasmValue

unWasmValue :: forall a. WasmValue a -> a
unWasmValue (WasmValue x) = x


class TableElem table a | a -> table where
  get :: Int -> table -> Effect (Maybe (WasmValue a))
  set :: Int -> table -> Maybe (WasmValue a) -> Effect Unit


getImpl :: forall a k. Int -> Table k -> Effect (Maybe (WasmValue a))
getImpl i table = map (map unsafeFromForeign) $ getRaw Nothing Just i table


setImpl :: forall a k. Int -> Table k -> Maybe (WasmValue a) -> Effect Unit
setImpl i table melem = setRaw i table $ maybe undefined unsafeToForeign melem


instance fn0TableElem :: TableElem (Table Anyfunc) (Effect a) where
  get = getImpl
  set = setImpl


instance fn1TableElem :: TableElem (Table Anyfunc) (EffectFn1 a b) where
  get = getImpl
  set = setImpl

instance fn2TableElem :: TableElem (Table Anyfunc) (EffectFn2 a b c) where
  get = getImpl
  set = setImpl

instance fn3TableElem :: TableElem (Table Anyfunc) (EffectFn3 a b c d) where
  get = getImpl
  set = setImpl

instance fn4TableElem :: TableElem (Table Anyfunc) (EffectFn4 a b c d e) where
  get = getImpl
  set = setImpl

instance fn5TableElem :: TableElem (Table Anyfunc) (EffectFn5 a b c d e f) where
  get = getImpl
  set = setImpl

instance fn6TableElem :: TableElem (Table Anyfunc) (EffectFn6 a b c d e f g) where
  get = getImpl
  set = setImpl

instance fn7TableElem :: TableElem (Table Anyfunc) (EffectFn7 a b c d e f g h) where
  get = getImpl
  set = setImpl

instance fn8TableElem :: TableElem (Table Anyfunc) (EffectFn8 a b c d e f g h i) where
  get = getImpl
  set = setImpl

instance fn9TableElem :: TableElem (Table Anyfunc) (EffectFn9 a b c d e f g h i j) where
  get = getImpl
  set = setImpl

instance fn10TableElem :: TableElem (Table Anyfunc) (EffectFn10 a b c d e f g h i j k) where
  get = getImpl
  set = setImpl


new :: forall k. STableKind (Table k) => { initial :: Int } -> Effect (Table k)
new desc =
  newRaw $ Record.insert (SProxy :: SProxy "element") (asRawTableKind (Proxy :: Proxy (Table k))) desc


newWithMaximum :: forall k. STableKind (Table k) => TableDescriptor -> Effect (Table k)
newWithMaximum desc =
  newWithMaximumRaw $ Record.insert (SProxy :: SProxy "element") (asRawTableKind (Proxy :: Proxy (Table k))) desc
