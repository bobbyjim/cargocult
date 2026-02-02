; Transpiled from Xenober16 to Prog8
; Module: SimpleOutput
; Author: Rob
; Description: Tests simple variable declarations, assignment, and output.

simpleoutput {























sub start() {
    message = 65
    txt.print(message)
    txt.nl()
    counter = 42
    txt.print(counter)
    txt.nl()
    txt.print("Hello, Commander X16!")
    txt.nl()
}
}