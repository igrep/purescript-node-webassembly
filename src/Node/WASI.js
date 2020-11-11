'use strict';

const { WASI } = require('wasi');

exports.new = options => new WASI(options);

exports.start = wasi => instance => () => wasi.start(instance);

exports.initialize = wasi => instance => () => wasi.initialize(instance);

exports.wasiImportRaw = wasi => wasi.wasiImport;
