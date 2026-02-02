; Transpiled from Xenober16 to Prog8
; Module: CaseTest
; Author: Rob
; Description: Tests CASE statements with ranges and multiple selectors.

casetest {























sub start() {
    day = 4
    txt.print("Day of week test")
    txt.nl()
    when day {
        0 -> {
            txt.print("Sunday")
            txt.nl()
        }
        1 -> {
            txt.print("Monday")
            txt.nl()
        }
        2 -> {
            txt.print("Tuesday")
            txt.nl()
        }
        3 -> {
            txt.print("Wednesday")
            txt.nl()
        }
        4 -> {
            txt.print("Thursday")
            txt.nl()
        }
        5 -> {
            txt.print("Friday")
            txt.nl()
        }
        6 -> {
            txt.print("Weekend")
            txt.nl()
        }
        7 -> {
            txt.print("Weekend")
            txt.nl()
        }
        else -> {
            txt.print("Invalid day")
            txt.nl()
        }
    }
    score = 25
    txt.print("Score range test")
    txt.nl()
    when score {
        1..10 -> {
            txt.print("Low range")
            txt.nl()
        }
        11..20 -> {
            txt.print("Medium-low range")
            txt.nl()
        }
        21..30 -> {
            txt.print("Medium range")
            txt.nl()
        }
        31..40 -> {
            txt.print("High range or exactly 50")
            txt.nl()
        }
        50 -> {
            txt.print("High range or exactly 50")
            txt.nl()
        }
        else -> {
            txt.print("Out of range")
            txt.nl()
        }
    }
}
}