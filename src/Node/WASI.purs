-- | Thin wrapper around WASI API of Node.js.
-- | See <https://nodejs.org/api/wasi.html> for details.
module Node.WASI
  ( WASI
  , NewOptions
  , new
  , start
  , initialize
  , wasiImportSnapshotPreview1
  , defaultNewOptions

  , wasiImportSnapshotPreview1Cooked
  , wasiImportRaw
  )
  where

import Prelude (Unit, ($))

import Effect (Effect)
import Foreign (Foreign)
import Foreign.Object (Object, empty, singleton)
import Partial.Unsafe (unsafePartial)

import Node.WebAssembly.ImportObject
  (ImportObject, ImportObjectRaw, cookImportObject, toImportObjectRaw)
import Node.WebAssembly.Instance (Instance)


foreign import data WASI :: Type

foreign import new :: NewOptions -> WASI

foreign import start :: WASI -> Instance -> Effect Unit

foreign import initialize :: WASI -> Instance -> Effect Unit

foreign import wasiImportRaw :: WASI -> Object Foreign


wasiImportSnapshotPreview1 :: WASI -> ImportObjectRaw
wasiImportSnapshotPreview1 wasi =
  unsafePartial $ toImportObjectRaw $ singleton "wasi_snapshot_preview1" $ wasiImportRaw wasi


wasiImportSnapshotPreview1Cooked :: WASI -> ImportObject
wasiImportSnapshotPreview1Cooked wasi = cookImportObject $ wasiImportSnapshotPreview1 wasi


type NewOptions =
  { args :: Array String
  , env :: Object String
  , preopens :: Object String
  , returnOnExit :: Boolean
  , stdin :: Int
  , stdout :: Int
  , stderr :: Int
  }


defaultNewOptions :: NewOptions
defaultNewOptions =
  { args: []
  , env: empty
  , preopens: empty
  , returnOnExit: false
  , stdin: 0
  , stdout: 1
  , stderr: 2
  }
