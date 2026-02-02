; Transpiled from Xenober16 to Prog8
; Module: LoopTest
; Author: Rob
; Description: Tests WHILE and REPEAT/UNTIL loops.

looptest {























sub start() {
    counter = 50
    txt.print("Counting down from 50 to 20")
    txt.nl()
    while (counter > 20) {
        counter = (counter - 5)
        txt.print(counter)
        txt.nl()
    }
    txt.print("Counting up to 30")
    txt.nl()
    repeat {
        counter = (counter + 1)
        txt.print(counter)
        txt.nl()
    } until (counter >= 30)
    total = 0
    counter = 1
    txt.print("Sum of 1 to 10")
    txt.nl()
    while (counter <= 10) {
        total = (total + counter)
        counter = (counter + 1)
    }
    txt.print(total)
    txt.nl()
}
}