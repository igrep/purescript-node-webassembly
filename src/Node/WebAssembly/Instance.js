exports.newRaw = imports => mod => _ => new WebAssembly.Instance(mod, imports);

exports.exportsRaw = instance => instance.exports;
