; Transpiled from Xenober16 to Prog8
; Module: ArrayTest
; Author: Rob
; Description: Tests array declarations, indexing, and operations.

arraytest {























sub start() {
    txt.print("Test 1: Array initialization")
    txt.nl()
    scores = 100
    scores = 85
    scores = 92
    txt.print(scores)
    txt.nl()
    txt.print(scores)
    txt.nl()
    txt.print(scores)
    txt.nl()
    txt.print("Test 2: Array loop initialization")
    txt.nl()
    for counter in 0 to 9 {
        scores = (counter * 10)
    }
    txt.print(scores)
    txt.nl()
    txt.print("Test 3: 16-bit array")
    txt.nl()
    positions = 0
    positions = 100
    positions = 200
    positions = 300
    txt.print(positions)
    txt.nl()
    txt.print(positions)
    txt.nl()
    txt.print("Test 4: Array summation")
    txt.nl()
    sum = 0
    for counter in 0 to 4 {
        sum = (sum + positions)
    }
    txt.print(sum)
    txt.nl()
    txt.print("Test 5: Char array (string-like)")
    txt.nl()
    message = 72
    message = 105
    message = 33
    txt.print(message)
    txt.nl()
    txt.print(message)
    txt.nl()
    txt.print("Test 6: Array bounds (within bounds)")
    txt.nl()
    value = scores
    txt.print(value)
    txt.nl()
    txt.print("Array tests complete")
    txt.nl()
}
}