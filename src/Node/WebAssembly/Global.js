'use strict';

exports.newRaw = desc => x =>
  new WebAssembly.Global(desc, x);
