module Node.WebAssembly.Memory
  ( Memory
  , new
  , newWithMaximum
  , MemoryDescriptor
  , buffer
  , grow
  ) where

import Data.ArrayBuffer.Types (ArrayBuffer)
import Effect (Effect)


foreign import data Memory :: Type

foreign import new :: { initial :: Int } -> Memory

foreign import newWithMaximum :: MemoryDescriptor -> Memory

foreign import buffer :: Memory -> Effect ArrayBuffer

foreign import grow :: Int -> Memory -> Effect Int

type MemoryDescriptor =
  { initial :: Int
  , maximum :: Int
  }
