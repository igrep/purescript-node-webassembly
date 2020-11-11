"use strict";

exports.newRaw = desc => new WebAssembly.Table(desc);

exports.newWithMaximumRaw = exports.new;

exports.getRaw = nothing => just => i => table => _ => {
  const result = table.get(i);
  if (result) {
    return just(result)
  }
  return nothing;
};

exports.setRaw = i => table => elem => _ => table.set(i, elem);

exports.grow = delta => table => _ => table.grow(delta);

exports.length = table => _ => table.length;

exports.undefined = undefined;
