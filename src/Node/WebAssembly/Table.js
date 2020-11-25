"use strict";

exports.newRaw = desc => () => new WebAssembly.Table(desc);

exports.newWithMaximumRaw = exports.new;

exports.getRaw = nothing => just => i => table => () => {
  const result = table.get(i);
  if (result) {
    return just(result)
  }
  return nothing;
};

exports.setRaw = i => table => elem => () => table.set(i, elem);

exports.grow = delta => table => () => table.grow(delta);

exports.length = table => () => table.length;

exports.undefined = undefined;
