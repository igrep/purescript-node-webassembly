module Node.WebAssembly.CompileError
  ( CompileError
  , new
  , fromError
  )
  where

import Data.Maybe (Maybe(..))
import Effect.Exception (Error)


type CompileError =
  { message :: String
  , name :: String
  -- NOTE: It seems that Node.js v14's WebAssembly.CompileError hasn't implemented these fields yet!
  --, fileName :: String
  --, lineNumber :: Int
  --, columnNumber :: Int
  }


foreign import new :: String -> String -> Int -> Error


foreign import fromErrorImpl
  :: Maybe CompileError -> (CompileError -> Maybe CompileError) -> Error -> Maybe CompileError

fromError :: Error -> Maybe CompileError
fromError e = fromErrorImpl Nothing Just e
