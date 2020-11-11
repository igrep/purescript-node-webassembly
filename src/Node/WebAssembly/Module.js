exports.new = array => new WebAssembly.Module(array);

exports.customSections = name => mod => WebAssembly.Module.customSections(mod, name);

exports.exportsRaw = mod => WebAssembly.Module.exports(mod);

exports.importsRaw = mod => WebAssembly.Module.imports(mod);
