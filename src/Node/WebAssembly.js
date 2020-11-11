exports.instantiateRawImpl = imports => buf => () => WebAssembly.instantiate(buf, imports);

exports.instantiateModuleRawImpl = exports.instantiateRawImpl;

exports.compileImpl = buf => () => WebAssembly.compile(buf);

exports.validate = buf => WebAssembly.validate(buf);
