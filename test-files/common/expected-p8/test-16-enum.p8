; Transpiled from Xenober16 to Prog8
; Module: ExpressionTest
; Author: Rob
; Description: Tests arithmetic expressions and operator precedence.

expressiontest {























sub start() {
    value = 10
    result = ((value * 2) + 5)
    txt.print(result)
    txt.nl()
    result = ((value + 5) * 2)
    txt.print(result)
    txt.nl()
    result = ((value * 2) + (1 * 10))
    txt.print(result)
    txt.nl()
    result = ((value - 3) + 2)
    txt.print(result)
    txt.nl()
}
}