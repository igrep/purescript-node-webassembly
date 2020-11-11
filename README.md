# purescript-node-webassembly

Experimental FFI wrappers around the WebAssembly-related API in Node.js.

## Current Status

It should work. But I don't publish it because.

- Tested only in Node.js v15.2 (the latest version as of writing this document).
    - Perhaps compatible with the browsers' API. But some of the browsers' features are not implemented yet (e.g. `compileStreaming`).
- Requires `--experimental-wasi-unstable-preview1` option to the `node` command.
    - See the "Running the Tests" section below when building with spago.

## Running the Tests

`spago test` doesn't work because you have to pass `--experimental-wasi-unstable-preview1` to node to run the tests:

```sh
spago build --then "node --experimental-wasi-unstable-preview1 runTest.js"
```

And to get a coverage report with `nyc` during the test:

```
spago build --purs-args="-g sourcemaps" --then "nyc node --experimental-wasi-unstable-preview1 runTest.js"
```
