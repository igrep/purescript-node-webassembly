# purescript-node-webassembly

Experimental FFI wrappers around the WebAssembly-related API in Node.js.

## Why?

I'm creating a new web service using WebAssembly on the server side.

## Current Status

It should work. But I don't publish it because:

- Tested only in Node.js v15.2 (the latest version as of writing this document).
    - Should be compatible with the browsers' API. But some of the browsers' features are not implemented yet (e.g. `compileStreaming`).
- Requires `--experimental-wasi-unstable-preview1` option to the `node` command.
    - See the "Running the Tests" section below when testing.

## Running the Tests

`spago test` doesn't work because you have to pass `--experimental-wasi-unstable-preview1` to node to run the tests:

```sh
spago build --then "node --experimental-wasi-unstable-preview1 runTest.js"
```

And to get a coverage report with `nyc` during the test:

```
spago build --purs-args="-g sourcemaps" --then "nyc node --experimental-wasi-unstable-preview1 runTest.js"
```

## Design Notes

### Nomenclature

To avoid name conflicts, this package contains exacly one module per one class (or object). So most of the wrapper methods have the same name with the wrapped methods in JavaScript. But there are some exceptions:

- Wrapped methods which return a `Promise` are `foreign import`-ed by a name prefixed with `Impl`.
    - E.g. `WebAssembly.compileImpl :: ArrayBuffer -> Effect (Promise Module)`
    - Then their `Aff` version is named without `Impl`.
        - E.g. `WebAssembly.compile :: ArrayBuffer -> Aff Module`
- Constructors are named with `new`.
    - E.g. `new WebAssembly.Module()` is wrapped by `WebAssembly.Module.new`.
- Wrapped method which accepts various types of arguments are named with several different prefixes by their arguments' types.
    - E.g. `new WebAssembly.Module({ initial })` is named as `WebAssembly.Module.new`
    - E.g. `new WebAssembly.Module({ initial, maximum })` is named as `WebAssembly.Module.newWithMaximum`
- Types which can be refined and the wrapped methods returning them and/or accepting them as the arguments are named prefixed with `Raw`.
    - E.g.
        - `WebAssembly.Module.exportsRaw :: Module -> Array ModuleExportDescriptorRaw`
        - And `WebAssembly.Module.exports :: Module -> Array ModuleExportDescriptor`
        - Where `ModuleExportDescriptorRaw` has `kind` as `String`
        - While `ModuleExportDescriptor` has `kind` as `ImportExportKind`

### Order of Arguments

Some wrapped methods' order of arguments are swapped for more useful partial application of them.
For example, `WebAssembly.instantiate(buf, imports)` is wrapped by `instantiateRaw :: ImportObjectRaw -> ArrayBuffer -> Aff ResultObject`.
