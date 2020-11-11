exports.isFunc =
  arity => value => typeof value === 'function' && value.length === arity;

exports.isTable = value => value instanceof WebAssembly.Table;

exports.isMemory = value => value instanceof WebAssembly.Memory;

exports.isGlobal = value => value instanceof WebAssembly.Global;

exports.toString = value => value.toString();
