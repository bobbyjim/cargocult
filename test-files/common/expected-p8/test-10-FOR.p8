; Transpiled from Xenober16 to Prog8
; Module: ForLoopTest
; Author: Rob
; Description: Tests FOR loop functionality with various patterns.

forlooptest {























sub start() {
    txt.print("Test 1: Basic FOR loop counting up")
    txt.nl()
    sum = 0
    for i in 0 to 10 {
        sum = (sum + i)
    }
    txt.print(sum)
    txt.nl()
    txt.print("Test 2: FOR loop with larger range")
    txt.nl()
    product = 1
    for i in 1 to 5 {
        product = (product * i)
    }
    txt.print(product)
    txt.nl()
    txt.print("Test 3: Nested FOR loops")
    txt.nl()
    counter = 0
    for i in 1 to 3 {
        txt.print(i)
        txt.nl()
    }
    txt.print("Test 4: FOR loop with step (if supported later)")
    txt.nl()
    txt.print("Complete")
    txt.nl()
}
}