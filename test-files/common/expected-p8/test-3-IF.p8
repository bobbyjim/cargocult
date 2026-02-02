; Transpiled from Xenober16 to Prog8
; Module: ConditionalTest
; Author: Rob
; Description: Tests IF/THEN/ELSIF/ELSE conditionals and comparisons.

conditionaltest {























sub start() {
    value = 101
    value = (value + 5)
    txt.print(value)
    txt.nl()
    if (value > 100) {
        txt.print("greater than 100")
        txt.nl()
    } else if (value > 60) {
        txt.print("greater than 60")
        txt.nl()
    } else if (value > 50) {
        txt.print("greater than 50")
        txt.nl()
    } else {
        txt.print("less than 51")
        txt.nl()
    }
    score = 85
    if (score >= 90) {
        txt.print("Grade A")
        txt.nl()
    } else if (score >= 80) {
        txt.print("Grade B")
        txt.nl()
    } else if (score >= 70) {
        txt.print("Grade C")
        txt.nl()
    } else {
        txt.print("Grade F")
        txt.nl()
    }
}
}