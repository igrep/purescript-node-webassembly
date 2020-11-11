-- | FFI wrapers around <https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/WebAssembly/Module>

module Node.WebAssembly.Module
  ( Module
  , new
  , customSections

  , exports
  , ModuleExportDescriptor
  , imports
  , ModuleImportDescriptor

  , exportsRaw
  , ModuleExportDescriptorRaw
  , importsRaw
  , ModuleImportDescriptorRaw
  
  , ImportExportKind (..)
  ) where

import Prelude

import Data.ArrayBuffer.Types (ArrayBuffer)
import Record (modify)
import Data.Symbol (SProxy (SProxy))
import Effect.Exception.Unsafe (unsafeThrow)


foreign import data Module :: Type

foreign import new :: ArrayBuffer -> Module

foreign import customSections :: String -> Module -> Array ArrayBuffer

foreign import exportsRaw :: Module -> Array ModuleExportDescriptorRaw

foreign import importsRaw :: Module -> Array ModuleImportDescriptorRaw

type ModuleExportDescriptorRaw = { name :: String, kind :: String }

type ModuleImportDescriptorRaw = { module :: String, name :: String, kind :: String }


exports :: Module -> Array ModuleExportDescriptor
exports mod = map (modify (SProxy :: SProxy "kind") readImportExportKind) (exportsRaw mod)

type ModuleExportDescriptor = { name :: String, kind :: ImportExportKind }


imports :: Module -> Array ModuleImportDescriptor
imports mod = map (modify (SProxy :: SProxy "kind") readImportExportKind) (importsRaw mod)

type ModuleImportDescriptor = { module :: String, name :: String, kind :: ImportExportKind }


data ImportExportKind = Function | Table | Memory | Global

derive instance eqImportExportKind :: Eq ImportExportKind

instance showImportExportKind :: Show ImportExportKind where
  show Function = "Function"
  show Table = "Table"
  show Memory = "Memory"
  show Global = "Global"


readImportExportKind :: String -> ImportExportKind
readImportExportKind "function" = Function
readImportExportKind "table" = Table
readImportExportKind "memory" = Memory
readImportExportKind "global" = Global
readImportExportKind s = unsafeThrow $ "Assertion failure: Unknown ImportExportKind: " <> show s
