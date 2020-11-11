exports.new = desc => new WebAssembly.Memory(desc);

exports.newWithMaximum = exports.new;

exports.buffer = mem => _ => mem.buffer;

exports.grow = delta => mem => _ => mem.grow(delta);
