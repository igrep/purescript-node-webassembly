(module
   (global $gI32 (import "js" "globalI32") (mut i32))
   ;; (global $gI64 (import "js" "globalI64") (mut i64))
   (global $gF32 (import "js" "globalF32") (mut f32))
   (global $gF64 (import "js" "globalF64") (mut f64))

   (func (export "getGlobalI32") (result i32)
        (global.get $gI32))
   (func (export "incGlobalI32")
        (global.set $gI32
            (i32.add (global.get $gI32) (i32.const 1))))

   ;; TODO: Support i64 with a native BigInt wrapper
   ;; (func (export "getGlobalI64") (result i64)
   ;;      (global.get $gI64))
   ;; (func (export "incGlobalI64")
   ;;      (global.set $gI64
   ;;          (i64.add (global.get $gI64) (i64.const 1))))

   (func (export "getGlobalF32") (result f32)
        (global.get $gF32))
   (func (export "incGlobalF32")
        (global.set $gF32
            (f32.add (global.get $gF32) (f32.const 1))))

   (func (export "getGlobalF64") (result f64)
        (global.get $gF64))
   (func (export "incGlobalF64")
        (global.set $gF64
            (f64.add (global.get $gF64) (f64.const 1))))
)
