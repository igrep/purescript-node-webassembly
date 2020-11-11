'use strict';

exports.new = message => fileName => lineNumber => 
  new WebAssembly.CompileError(message, fileName, lineNumber);

exports.fromErrorImpl = nothing => just => e => {
  if (e instanceof WebAssembly.CompileError){
    return just(e);
  }
  return nothing;
};
