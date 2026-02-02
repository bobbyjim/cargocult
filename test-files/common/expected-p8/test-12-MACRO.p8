; Transpiled from Xenober16 to Prog8
; Module: MacroTest
; Author: Rob
; Description: Tests macro system with constants and code macros.

macrotest {







const MAX_SPRITES = 128
const SCREEN_WIDTH = 320
const SCREEN_HEIGHT = 240
const CHAR_RANGE = 'A'..'Z'
const DIGIT_RANGE = '0'..'9'











sub increment( ubyte x) {
    x = (x + 1)
}

sub clamp( ubyte value, ubyte min, ubyte max) {
    if (value < min) {
        return min
    }
    if (value > max) {
        return max
    }
    return value
}

sub swap( ubyte a, ubyte b) {
    ; TODO: Xenober16::AST::VarDeclNode
    temp = a
    a = b
    b = temp
}



sub start() {
    txt.print("Testing macro constants")
    txt.nl()
    max = MAX_SPRITES
    txt.print(max)
    txt.nl()
    txt.print("Testing code macros")
    txt.nl()
    x = 5
    increment(x)
    txt.print(x)
    txt.nl()
    x = 200
    result = clamp(x, 0, 100)
    txt.print(result)
    txt.nl()
    x = 10
    y = 20
    swap(x, y)
    txt.print(x)
    txt.nl()
    txt.print(y)
    txt.nl()
    txt.print("Macro test complete")
    txt.nl()
}
}