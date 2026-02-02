; Transpiled from Xenober16 to Prog8
; Module: ConstantsTest
; Author: Rob
; Description: Tests CONSTANTS DIVISION and constant usage.

constantstest {







const max-value = 100
const min-value = 10
const pi = 3
const greeting = "Hello from constants!"















sub start() {
    txt.print(greeting)
    txt.nl()
    value = max-value
    txt.print(value)
    txt.nl()
    result = (max-value - min-value)
    txt.print(result)
    txt.nl()
    if (value >= max-value) {
        txt.print("At maximum")
        txt.nl()
    } else if (value <= min-value) {
        txt.print("At minimum")
        txt.nl()
    } else {
        txt.print("In range")
        txt.nl()
    }
}
}