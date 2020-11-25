exports.new = desc => () => new WebAssembly.Memory(desc);

exports.newWithMaximum = exports.new;

exports.buffer = mem => () => mem.buffer;

exports.grow = delta => mem => () => mem.grow(delta);
