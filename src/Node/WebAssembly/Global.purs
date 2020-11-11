module Node.WebAssembly.Global
  ( Global
  , GlobalDescriptor
  , newRaw
  , class ToGlobal
  , new
  , F32 (..)
  -- , I64 (..)
  , Mutable (..)
  ) where

import Data.Newtype (class Newtype)

foreign import data Global :: Type


type GlobalDescriptor =
  { value :: String
  , mutable :: Boolean
  }


newtype Mutable = Mutable Boolean
derive instance newtypeMutable :: Newtype Mutable _


class ToGlobal a where
  new :: Mutable -> a -> Global


instance toGlobalInt :: ToGlobal Int where
  new (Mutable b) i = newRaw { value: "i32", mutable: b } i


-- FIXME: Make with the native BigInt implementation.
--instance toGlobalBigInt :: ToGlobal BigInt where
  --new (Mutable b) i = newRaw { value: "i64", mutable: b } i


newtype F32 = F32 Number
derive instance newtypeF32 :: Newtype F32 _

instance toGlobalF32 :: ToGlobal F32 where
  new (Mutable b) (F32 f) = newRaw { value: "f32", mutable: b } f


instance toGlobalNumber :: ToGlobal Number where
  new (Mutable b) num = newRaw { value: "f64", mutable: b } num


foreign import newRaw :: forall a. GlobalDescriptor -> a -> Global
