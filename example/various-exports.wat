(module
    (func $funcExported (export "func") (result i32) (i32.const 50))
    (table $tblExported (export "tbl") 10 anyfunc)
    (memory $memExported (export "mem") 100)
    (global $glblExported (export "glbl") (mut i32) (i32.const 200))
)
