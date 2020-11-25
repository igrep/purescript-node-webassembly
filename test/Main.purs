module Test.Main where

import Prelude

import Control.Monad.Error.Class (class MonadThrow)
import Data.Array as Array
import Data.ArrayBuffer.ArrayBuffer as ArrayBuffer
import Data.ArrayBuffer.Class (byteLength, putArrayBuffer)
import Data.ArrayBuffer.Class.Types (Int32LE (Int32LE))
import Data.ArrayBuffer.Types (ArrayBuffer)
import Data.Bifunctor (lmap)
import Data.Either (Either (Left))
import Data.Foldable (for_, sum)
import Data.FoldableWithIndex (forWithIndex_)
import Data.Maybe (Maybe (Nothing, Just), fromJust, isNothing)
import Data.Tuple (Tuple (Tuple))
import Data.Unfoldable (replicateA)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_, try, throwError)
import Effect.Class (liftEffect)
import Effect.Exception (Error, error)
import Effect.Exception.Unsafe (unsafeThrow)
import Effect.Random (randomInt)
import Effect.Uncurried
  ( EffectFn1, EffectFn2, EffectFn3, EffectFn4, EffectFn5, EffectFn6, EffectFn7, EffectFn8, EffectFn9, EffectFn10
  , mkEffectFn1, mkEffectFn2, mkEffectFn3, mkEffectFn4, mkEffectFn5, mkEffectFn6, mkEffectFn7, mkEffectFn8, mkEffectFn9, mkEffectFn10
  , runEffectFn1, runEffectFn2, runEffectFn3, runEffectFn4, runEffectFn5, runEffectFn6, runEffectFn7, runEffectFn8, runEffectFn9, runEffectFn10
  )
import Foreign (Foreign, unsafeFromForeign, unsafeToForeign)
import Foreign.Object as Object
import Node.Buffer as Buffer
import Node.FS.Aff as FS
import Partial.Unsafe (unsafePartial)
import Test.Spec (describe, it)
import Test.Spec.Assertions (fail, shouldEqual, shouldReturn, shouldSatisfy)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)
import Type.Proxy (Proxy (Proxy))

import Node.WASI as WASI
import Node.WASI (WASI)
import Node.WebAssembly as WebAssembly
import Node.WebAssembly.CompileError as CompileError
import Node.WebAssembly.Exports as Exports
import Node.WebAssembly.Exports (Exports)
import Node.WebAssembly.Global as Global
import Node.WebAssembly.ImportObject as ImportObject
import Node.WebAssembly.ImportObject (ImportObject)
import Node.WebAssembly.Instance (Instance)
import Node.WebAssembly.Instance as Instance
import Node.WebAssembly.Memory as Memory
import Node.WebAssembly.Module (Module)
import Node.WebAssembly.Module as Module
import Node.WebAssembly.Table (Anyfunc, Table, class TableElem, WasmValue, unWasmValue)
import Node.WebAssembly.Table as Table

foreign import isAWebAssemblyInstance :: Instance -> Boolean

type WasiCase =
  { name :: String
  , createInstance :: WASI -> Aff Instance
  }


main :: Effect Unit
main = launchAff_ $ runSpec [consoleReporter] do
  describe "Node.WASI" do
    let cases =
          [ { name: "instantiateRaw"
            , createInstance:
                \wasi ->
                  map (_.instance)
                    <<< WebAssembly.instantiateRaw (WASI.wasiImportSnapshotPreview1 wasi)
                    =<< readExampleFile "stdout.wasm"
            }
          , { name: "instantiate"
            , createInstance:
                \wasi ->
                  map (_.instance)
                    <<< WebAssembly.instantiate (WASI.wasiImportSnapshotPreview1Cooked wasi)
                    =<< readExampleFile "stdout.wasm"
            }
          , { name: "instantiateModuleRaw"
            , createInstance:
                \wasi ->
                  WebAssembly.instantiateModuleRaw (WASI.wasiImportSnapshotPreview1 wasi)
                    =<< compileExampleFile "stdout.wasm"
            }
          , { name: "instantiateModule"
            , createInstance:
                \wasi ->
                  WebAssembly.instantiateModule (WASI.wasiImportSnapshotPreview1Cooked wasi)
                    =<< compileExampleFile "stdout.wasm"
            }
          ]

    for_ cases \{ name, createInstance } -> do
      it ("can start a WASI executable successfully with " <> name) do
        let wasi = WASI.new WASI.defaultNewOptions
        wasm <- createInstance wasi
        -- WISH: Capture stdout
        liftEffect $ WASI.start wasi wasm

  describe "Node.WebAssembly" do
    describe ".validate" do
      it "should return true given a valid wasm file" do
        buf <- readExampleFile "stdout.wasm"
        WebAssembly.validate buf `shouldEqual` true

      it "should return false given a invalid wasm file" do
        buf <- readExampleFile "empty"
        WebAssembly.validate buf `shouldEqual` false

  describe "Node.WebAssembly.CompileError" do
    it "should be catched as an ordinary error" do
      result <- try $ throwError (CompileError.new "msg" "file.wasm" 100)
      let expected = { message: "msg", name: "CompileError" }
      lmap CompileError.fromError (result :: Either Error Unit) `shouldEqual` Left (Just expected)

    it "should not be created from the other kind of error" do
      result <- try $ throwError $ error "other error"
      lmap CompileError.fromError (result :: Either Error Unit) `shouldEqual` Left Nothing

  describe "Node.WebAssembly.Global.new" do
    let imports = Object.singleton "js" $ Object.fromFoldable
          [ Tuple "globalI32" $ ImportObject.Global $ Global.new (Global.Mutable true) 1
          -- , Tuple "globalI64" $ Global $ Global.new (Global.Mutable true) $ toBigInt 2
          , Tuple "globalF32" $ ImportObject.Global $ Global.new (Global.Mutable true) $ Global.F32 3.25
          , Tuple "globalF64" $ ImportObject.Global $ Global.new (Global.Mutable true) 4.5
          ]

    it "can create a mutable global variable with type i32" do
      exports <- getExportsOfExampleFile "global.wasm" imports
      getResult1 <- unsafeRunFunc0 "getGlobalI32" exports
      _ <- unsafeRunFunc0 "incGlobalI32" exports :: Aff Unit
      getResult2 <- unsafeRunFunc0 "getGlobalI32" exports
      getResult1 `shouldEqual` 1
      getResult2 `shouldEqual` 2

    it "can create a mutable global variable with type f32" do
      exports <- getExportsOfExampleFile "global.wasm" imports
      getResult1 <- unsafeRunFunc0 "getGlobalF32" exports
      _ <- unsafeRunFunc0 "incGlobalF32" exports :: Aff Unit
      getResult2 <- unsafeRunFunc0 "getGlobalF32" exports
      getResult1 `shouldEqual` 3.25
      getResult2 `shouldEqual` 4.25

    it "can create a mutable global variable with type f64" do
      exports <- getExportsOfExampleFile "global.wasm" imports
      getResult1 <- unsafeRunFunc0 "getGlobalF64" exports
      _ <- unsafeRunFunc0 "incGlobalF64" exports :: Aff Unit
      getResult2 <- unsafeRunFunc0 "getGlobalF64" exports
      getResult1 `shouldEqual` 4.5
      getResult2 `shouldEqual` 5.5

  describe "Node.WebAssembly.Instance" do
    describe "new" do
      it "initializes a new instance with various kinds of imports" do
        mod <- compileExampleFile "various-imports.wasm"
        tbl <- liftEffect $ Table.new { initial: 1 }
        mem <- liftEffect $ Memory.new { initial: 10 }
        let glbl = Global.new (Global.Mutable false) 2
            imports = Object.singleton "js" $ Object.fromFoldable
              [ Tuple "f00" $ ImportObject.Func0 $ pure fZero
              , Tuple "f01" $ ImportObject.Func1 $ mkEffectFn1 $ \_ -> pure fZero
              , Tuple "f02" $ ImportObject.Func2 $ mkEffectFn2 $ \_ _ -> pure fZero
              , Tuple "f03" $ ImportObject.Func3 $ mkEffectFn3 $ \_ _ _ -> pure fZero
              , Tuple "f04" $ ImportObject.Func4 $ mkEffectFn4 $ \_ _ _ _ -> pure fZero
              , Tuple "f05" $ ImportObject.Func5 $ mkEffectFn5 $ \_ _ _ _ _ -> pure fZero
              , Tuple "f06" $ ImportObject.Func6 $ mkEffectFn6 $ \_ _ _ _ _ _ -> pure fZero
              , Tuple "f07" $ ImportObject.Func7 $ mkEffectFn7 $ \_ _ _ _ _ _ _ -> pure fZero
              , Tuple "f08" $ ImportObject.Func8 $ mkEffectFn8 $ \_ _ _ _ _ _ _ _ -> pure fZero
              , Tuple "f09" $ ImportObject.Func9 $ mkEffectFn9 $ \_ _ _ _ _ _ _ _ _ -> pure fZero
              , Tuple "f10" $ ImportObject.Func10 $ mkEffectFn10 $ \_ _ _ _ _ _ _ _ _ _ -> pure fZero
              , Tuple "tbl" $ ImportObject.TableAnyfunc tbl
              , Tuple "mem" $ ImportObject.Memory mem
              , Tuple "glbl" $ ImportObject.Global glbl
              ]

        inst <- liftEffect $ Instance.new imports mod
        unless (isAWebAssemblyInstance inst) $ fail "Not an instance of WebAssembly.Instance."

    describe "exports" do
      it "gets various kinds of exports" do
        mod <- compileExampleFile "various-exports.wasm"
        inst <- liftEffect $ Instance.new Object.empty mod
        let exports = Instance.exports inst 

        unsafeRunFunc0 "func" exports `shouldReturn` 50

        case Exports.getTableAnyfunc "tbl" exports of
            Just _tbl -> pure unit
            Nothing -> fail "Can't get table"

        case Exports.getMemory "mem" exports of
            Just _mem -> pure unit
            Nothing -> fail "Can't get memory"

        case Exports.getGlobal "glbl" exports of
            Just _glbl -> pure unit
            Nothing -> fail "Can't get global"

  describe "Node.WebAssembly.Memory" do
    describe "new" do
      it "can create readable/writable instance of WebAssembly.Memory" do
        mem <- liftEffect $ Memory.newWithMaximum { initial: 10, maximum: 20 } 
        buf <- liftEffect $ Memory.buffer mem
        ints :: Array Int <- liftEffect $ replicateA 10 (randomInt 0 9)
        liftEffect $ forWithIndex_ ints \ix int -> do
          let i32 = Int32LE int
          len <- byteLength i32
          mwritten <- putArrayBuffer buf (len * ix) i32
          case mwritten of
              Just _ -> pure unit
              Nothing -> fail $ "Failed to write at " <> show ix <> "."

        let imports = Object.singleton "js" $ Object.singleton "mem" $ ImportObject.Memory mem
        exports <- getExportsOfExampleFile "memory.wasm" imports
        result <- unsafeRunFunc2 "accumulate" fZero (unsafeToForeign 10) exports
        result `shouldEqual` sum ints

    describe "grow" do
      it "increases the buffer size" do
        let bytesPerPage = 64 * 1024
        initial <- liftEffect $ randomInt 1 5
        mem <- liftEffect $ Memory.new { initial }
        sizeBeforeGrow <- liftEffect $ map ArrayBuffer.byteLength $ Memory.buffer mem
        sizeBeforeGrow `shouldEqual` (initial * bytesPerPage)

        sizeToGrowBy <- liftEffect $ randomInt 1 5
        result <- liftEffect $ Memory.grow sizeToGrowBy mem
        result `shouldEqual` initial

        sizeAfterGrow <- liftEffect $ map ArrayBuffer.byteLength $ Memory.buffer mem
        sizeAfterGrow `shouldEqual` ((initial + sizeToGrowBy) * bytesPerPage)

  describe "Node.WebAssembly.Module" do
    describe "customSections" do
      it "returns custom sections" do
        mod <- compileExampleFile "custom-section.wasm"
        let result = Module.customSections "name" mod
        Array.length result `shouldEqual` 1
        let byteLength = ArrayBuffer.byteLength $ unsafePartial $ fromJust $ Array.head result 
        byteLength `shouldSatisfy` (_ > 0)

    describe "exports" do
      it "detects various kind of exports" do
        mod <- compileExampleFile "various-exports.wasm"
        Module.exports mod `shouldEqual`
          [ { name: "func", kind: Module.Function }
          , { name: "tbl", kind: Module.Table }
          , { name: "mem", kind: Module.Memory }
          , { name: "glbl", kind: Module.Global }
          ]

    describe "imports" do
      it "detects various kind of imports" do
        mod <- compileExampleFile "various-imports.wasm"
        Module.imports mod `shouldEqual`
          [ { module: "js", name: "f00", kind: Module.Function }
          , { module: "js", name: "f01", kind: Module.Function }
          , { module: "js", name: "f02", kind: Module.Function }
          , { module: "js", name: "f03", kind: Module.Function }
          , { module: "js", name: "f04", kind: Module.Function }
          , { module: "js", name: "f05", kind: Module.Function }
          , { module: "js", name: "f06", kind: Module.Function }
          , { module: "js", name: "f07", kind: Module.Function }
          , { module: "js", name: "f08", kind: Module.Function }
          , { module: "js", name: "f09", kind: Module.Function }
          , { module: "js", name: "f10", kind: Module.Function }
          , { module: "js", name: "tbl", kind: Module.Table }
          , { module: "js", name: "mem", kind: Module.Memory }
          , { module: "js", name: "glbl", kind: Module.Global }
          ]

  describe "Node.WebAssembly.Table" do
    let tableSize = 11

    describe "get" do
      it "all functions not set at first" do
        table :: Table Anyfunc <- liftEffect $ Table.new { initial: tableSize }
        let shouldReturnNothing :: forall effectFn. TableElem (Table Anyfunc) effectFn => Int -> Proxy effectFn -> Aff Unit
            shouldReturnNothing i _proxy =
              map (map unWasmValue) (liftEffect $ Table.get i table) `shouldReturnSatisfy` (isNothing :: Maybe effectFn -> Boolean)

        shouldReturnNothing 0 (Proxy :: Proxy (Effect Int))
        shouldReturnNothing 1 (Proxy :: Proxy (EffectFn1 Int Int))
        shouldReturnNothing 2 (Proxy :: Proxy (EffectFn2 Int Int Int))
        shouldReturnNothing 3 (Proxy :: Proxy (EffectFn3 Int Int Int Int))
        shouldReturnNothing 4 (Proxy :: Proxy (EffectFn4 Int Int Int Int Int))
        shouldReturnNothing 5 (Proxy :: Proxy (EffectFn5 Int Int Int Int Int Int))
        shouldReturnNothing 6 (Proxy :: Proxy (EffectFn6 Int Int Int Int Int Int Int))
        shouldReturnNothing 7 (Proxy :: Proxy (EffectFn7 Int Int Int Int Int Int Int Int))
        shouldReturnNothing 8 (Proxy :: Proxy (EffectFn8 Int Int Int Int Int Int Int Int Int))
        shouldReturnNothing 9 (Proxy :: Proxy (EffectFn9 Int Int Int Int Int Int Int Int Int Int))
        shouldReturnNothing 10 (Proxy :: Proxy (EffectFn10 Int Int Int Int Int Int Int Int Int Int Int))

      it "can get functions saved in the table after importing to a wasm module" do
        table :: Table Anyfunc <- liftEffect $ Table.new { initial: tableSize }
        let imports = Object.singleton "js" $ Object.singleton "tbl" $ ImportObject.TableAnyfunc table
        exports <- getExportsOfExampleFile "table-imported.wasm" imports

        let shouldReturnExportedFunction
              :: forall effectFn. TableElem (Table Anyfunc) effectFn
              => Int
              -> (effectFn -> Effect Int)
              -> (Exports -> Aff Int)
              -> Aff Unit
            shouldReturnExportedFunction i runTableElem runExported = do
              tentry :: (Maybe (WasmValue effectFn)) <- liftEffect $ Table.get i table
              tval <- liftEffect $ runTableElem $ unWasmValue $ unsafePartial $ fromJust tentry
              expected <- runExported exports
              tval `shouldEqual` expected

        shouldReturnExportedFunction 0 (\e -> e) (unsafeRunFunc0 "f1_00")
        shouldReturnExportedFunction 1 (\e -> runEffectFn1 e 0) (unsafeRunFunc1 "f1_01" fZero)
        shouldReturnExportedFunction 2 (\e -> runEffectFn2 e 0 0) (unsafeRunFunc2 "f1_02" fZero fZero)
        shouldReturnExportedFunction 3 (\e -> runEffectFn3 e 0 0 0) (unsafeRunFunc3 "f1_03" fZero fZero fZero)
        shouldReturnExportedFunction 4 (\e -> runEffectFn4 e 0 0 0 0) (unsafeRunFunc4 "f1_04" fZero fZero fZero fZero)
        shouldReturnExportedFunction 5 (\e -> runEffectFn5 e 0 0 0 0 0) (unsafeRunFunc5 "f1_05" fZero fZero fZero fZero fZero)
        shouldReturnExportedFunction 6 (\e -> runEffectFn6 e 0 0 0 0 0 0) (unsafeRunFunc6 "f1_06" fZero fZero fZero fZero fZero fZero)
        shouldReturnExportedFunction 7 (\e -> runEffectFn7 e 0 0 0 0 0 0 0) (unsafeRunFunc7 "f1_07" fZero fZero fZero fZero fZero fZero fZero)
        shouldReturnExportedFunction 8 (\e -> runEffectFn8 e 0 0 0 0 0 0 0 0) (unsafeRunFunc8 "f1_08" fZero fZero fZero fZero fZero fZero fZero fZero)
        shouldReturnExportedFunction 9 (\e -> runEffectFn9 e 0 0 0 0 0 0 0 0 0) (unsafeRunFunc9 "f1_09" fZero fZero fZero fZero fZero fZero fZero fZero fZero)
        shouldReturnExportedFunction 10 (\e -> runEffectFn10 e 0 0 0 0 0 0 0 0 0 0) (unsafeRunFunc10 "f1_10" fZero fZero fZero fZero fZero fZero fZero fZero fZero fZero)

    describe "set" do
      it "Can replace functions in the table" do
        table :: Table Anyfunc <- liftEffect $ Table.new { initial: tableSize }
        let imports = Object.singleton "js" $ Object.singleton "tbl" $ ImportObject.TableAnyfunc table
        exports <- getExportsOfExampleFile "table-imported.wasm" imports

        let shouldReturnReplacedFunctionAfterSet
              :: forall effectFn. TableElem (Table Anyfunc) effectFn
              => Int
              -> (effectFn -> Effect Foreign)
              -> WasmValue effectFn
              -> Aff Unit
            shouldReturnReplacedFunctionAfterSet i run exportedFn = do
              liftEffect $ Table.set i table (Just exportedFn)
              tentry :: (Maybe (WasmValue effectFn)) <- liftEffect $ Table.get i table
              tval :: Int <- liftEffect $ map unsafeFromForeign $ run $ unWasmValue $ unsafePartial $ fromJust tentry
              expected :: Int <- liftEffect $ map unsafeFromForeign $ run $ unWasmValue $ exportedFn
              tval `shouldEqual` expected

        let eff0 = unsafePartial $ fromJust $ Exports.getFunc0 "f2_00" exports
        shouldReturnReplacedFunctionAfterSet 0 (\e -> e) eff0

        let eff1 = unsafePartial $ fromJust $ Exports.getFunc1 "f2_01" exports
        shouldReturnReplacedFunctionAfterSet 1 (\e -> runEffectFn1 e fZero) eff1

        let eff2 = unsafePartial $ fromJust $ Exports.getFunc2 "f2_02" exports
        shouldReturnReplacedFunctionAfterSet 2 (\e -> runEffectFn2 e fZero fZero) eff2

        let eff3 = unsafePartial $ fromJust $ Exports.getFunc3 "f2_03" exports
        shouldReturnReplacedFunctionAfterSet 3 (\e -> runEffectFn3 e fZero fZero fZero) eff3

        let eff4 = unsafePartial $ fromJust $ Exports.getFunc4 "f2_04" exports
        shouldReturnReplacedFunctionAfterSet 4 (\e -> runEffectFn4 e fZero fZero fZero fZero) eff4

        let eff5 = unsafePartial $ fromJust $ Exports.getFunc5 "f2_05" exports
        shouldReturnReplacedFunctionAfterSet 5 (\e -> runEffectFn5 e fZero fZero fZero fZero fZero) eff5

        let eff6 = unsafePartial $ fromJust $ Exports.getFunc6 "f2_06" exports
        shouldReturnReplacedFunctionAfterSet 6 (\e -> runEffectFn6 e fZero fZero fZero fZero fZero fZero) eff6

        let eff7 = unsafePartial $ fromJust $ Exports.getFunc7 "f2_07" exports
        shouldReturnReplacedFunctionAfterSet 7 (\e -> runEffectFn7 e fZero fZero fZero fZero fZero fZero fZero) eff7

        let eff8 = unsafePartial $ fromJust $ Exports.getFunc8 "f2_08" exports
        shouldReturnReplacedFunctionAfterSet 8 (\e -> runEffectFn8 e fZero fZero fZero fZero fZero fZero fZero fZero) eff8

        let eff9 = unsafePartial $ fromJust $ Exports.getFunc9 "f2_09" exports
        shouldReturnReplacedFunctionAfterSet 9 (\e -> runEffectFn9 e fZero fZero fZero fZero fZero fZero fZero fZero fZero) eff9

        let eff10 = unsafePartial $ fromJust $ Exports.getFunc10 "f2_10" exports
        shouldReturnReplacedFunctionAfterSet 10 (\e -> runEffectFn10 e fZero fZero fZero fZero fZero fZero fZero fZero fZero fZero) eff10


    describe "grow" do
      it "can increase the length of the table" $ liftEffect do
        initial <- randomInt 1 10
        table :: Table Anyfunc <- Table.new { initial }
        Table.length table `shouldReturn` initial

        delta <- randomInt 5 15
        Table.grow delta table `shouldReturn` initial
        Table.length table `shouldReturn` (initial + delta)


readExampleFile :: String -> Aff ArrayBuffer
readExampleFile fileName = liftEffect <<< Buffer.toArrayBuffer =<< FS.readFile ("example/" <> fileName)


compileExampleFile :: String -> Aff Module
compileExampleFile fileName = WebAssembly.compile =<< readExampleFile fileName


getExportsOfExampleFile :: String -> ImportObject -> Aff Exports
getExportsOfExampleFile fileName imports =
  map Instance.exports <<< (liftEffect <<< Instance.new imports) <<< Module.new =<< readExampleFile fileName


unsafeRunFunc0 :: forall a. String -> Exports -> Aff a
unsafeRunFunc0 key exports =
  case Object.lookup key exports of
      Just (Exports.Func0 eff) -> liftEffect $ map unsafeFromForeign (unWasmValue eff)
      _other -> unsafeThrow $ "Unexpected exported value in " <> key


unsafeRunFunc1 :: forall a. String -> Foreign -> Exports -> Aff a
unsafeRunFunc1 key x1 exports =
  case Object.lookup key exports of
      Just (Exports.Func1 eff) -> liftEffect $ map unsafeFromForeign $ runEffectFn1 (unWasmValue eff) x1
      _other -> unsafeThrow $ "Unexpected exported value in " <> key


unsafeRunFunc2 :: forall a. String -> Foreign -> Foreign -> Exports -> Aff a
unsafeRunFunc2 key x1 x2 exports =
  case Object.lookup key exports of
      Just (Exports.Func2 eff) -> liftEffect $ map unsafeFromForeign $ runEffectFn2 (unWasmValue eff) x1 x2
      _other -> unsafeThrow $ "Unexpected exported value in " <> key


unsafeRunFunc3 :: forall a. String -> Foreign -> Foreign -> Foreign -> Exports -> Aff a
unsafeRunFunc3 key x1 x2 x3 exports =
  case Object.lookup key exports of
      Just (Exports.Func3 eff) -> liftEffect $ map unsafeFromForeign $ runEffectFn3 (unWasmValue eff) x1 x2 x3
      _other -> unsafeThrow $ "Unexpected exported value in " <> key


unsafeRunFunc4 :: forall a. String -> Foreign -> Foreign -> Foreign -> Foreign -> Exports -> Aff a
unsafeRunFunc4 key x1 x2 x3 x4 exports =
  case Object.lookup key exports of
      Just (Exports.Func4 eff) -> liftEffect $ map unsafeFromForeign $ runEffectFn4 (unWasmValue eff) x1 x2 x3 x4
      _other -> unsafeThrow $ "Unexpected exported value in " <> key


unsafeRunFunc5 :: forall a. String -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Exports -> Aff a
unsafeRunFunc5 key x1 x2 x3 x4 x5 exports =
  case Object.lookup key exports of
      Just (Exports.Func5 eff) -> liftEffect $ map unsafeFromForeign $ runEffectFn5 (unWasmValue eff) x1 x2 x3 x4 x5
      _other -> unsafeThrow $ "Unexpected exported value in " <> key


unsafeRunFunc6 :: forall a. String -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Exports -> Aff a
unsafeRunFunc6 key x1 x2 x3 x4 x5 x6 exports =
  case Object.lookup key exports of
      Just (Exports.Func6 eff) -> liftEffect $ map unsafeFromForeign $ runEffectFn6 (unWasmValue eff) x1 x2 x3 x4 x5 x6
      _other -> unsafeThrow $ "Unexpected exported value in " <> key


unsafeRunFunc7 :: forall a. String -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Exports -> Aff a
unsafeRunFunc7 key x1 x2 x3 x4 x5 x6 x7 exports =
  case Object.lookup key exports of
      Just (Exports.Func7 eff) -> liftEffect $ map unsafeFromForeign $ runEffectFn7 (unWasmValue eff) x1 x2 x3 x4 x5 x6 x7
      _other -> unsafeThrow $ "Unexpected exported value in " <> key


unsafeRunFunc8 :: forall a. String -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Exports -> Aff a
unsafeRunFunc8 key x1 x2 x3 x4 x5 x6 x7 x8 exports =
  case Object.lookup key exports of
      Just (Exports.Func8 eff) -> liftEffect $ map unsafeFromForeign $ runEffectFn8 (unWasmValue eff) x1 x2 x3 x4 x5 x6 x7 x8
      _other -> unsafeThrow $ "Unexpected exported value in " <> key


unsafeRunFunc9 :: forall a. String -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Exports -> Aff a
unsafeRunFunc9 key x1 x2 x3 x4 x5 x6 x7 x8 x9 exports =
  case Object.lookup key exports of
      Just (Exports.Func9 eff) -> liftEffect $ map unsafeFromForeign $ runEffectFn9 (unWasmValue eff) x1 x2 x3 x4 x5 x6 x7 x8 x9
      _other -> unsafeThrow $ "Unexpected exported value in " <> key


unsafeRunFunc10 :: forall a. String -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Foreign -> Exports -> Aff a
unsafeRunFunc10 key x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 exports =
  case Object.lookup key exports of
      Just (Exports.Func10 eff) -> liftEffect $ map unsafeFromForeign $ runEffectFn10 (unWasmValue eff) x1 x2 x3 x4 x5 x6 x7 x8 x9 x10
      _other -> unsafeThrow $ "Unexpected exported value in " <> key


shouldReturnSatisfy
  :: forall m t
   . MonadThrow Error m
  => m t
  -> (t -> Boolean)
  -> m Unit
shouldReturnSatisfy a pred = do
  v <- a
  unless (pred v) $ fail $ "doesn't satisfy predicate"


fZero :: Foreign
fZero = unsafeToForeign 0
