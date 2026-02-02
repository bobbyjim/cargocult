; Transpiled from Xenober16 to Prog8
; Module: ProcedureTest
; Author: Rob
; Description: Tests procedure definitions and calls with parameters.

proceduretest {



















sub greet( ubyte name) {
    txt.print("Hello")
    txt.nl()
    txt.print(name)
    txt.nl()
}

sub add( ubyte a, ubyte b) {
    result = (a + b)
    txt.print(result)
    txt.nl()
}

sub multiply( ubyte a, ubyte b) {
    result = (a * b)
    txt.print(result)
    txt.nl()
}



sub start() {
    x = 10
    y = 5
    greet(42)
    txt.print("Addition test")
    txt.nl()
    add(x, y)
    txt.print("Multiplication test")
    txt.nl()
    multiply(x, y)
    add(100, 50)
}
}