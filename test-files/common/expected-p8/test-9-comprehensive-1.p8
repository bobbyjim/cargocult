; Transpiled from Xenober16 to Prog8
; Module: AdvancedTest
; Author: Rob
; Description: Comprehensive test combining multiple language features.

advancedtest {







const screen-width = 80
const screen-height = 60
const max-iterations = 100



; Memory area screen-buffer in BANK 1 at $A000 (size: 4800)
&uword screen-buffer = $A000  ; bank: 1
&uword sprite-data = $400  ; size: 1024







sub initialize() {
    x = 0
    y = 0
    counter = 0
    total = 0
    txt.print("Initialized")
    txt.nl()
}

sub calculate( ubyte a, ubyte b) {
    total = (a + b)
    if (total > screen-width) {
        total = screen-width
    }
}

sub process-status( ubyte code) {
    when code {
        0 -> {
            txt.print("Ready")
            txt.nl()
        }
        1..5 -> {
            txt.print("Processing")
            txt.nl()
        }
        6..10 -> {
            txt.print("Complete")
            txt.nl()
        }
        else -> {
            txt.print("Error")
            txt.nl()
        }
    }
}



sub start() {
    initialize()
    txt.print("Starting main loop")
    txt.nl()
    counter = 0
    while (counter < 10) {
        x = (counter * 2)
        y = (counter + 5)
        calculate(x, y)
        txt.print(total)
        txt.nl()
        counter = (counter + 1)
    }
    status = 3
    process-status(status)
    txt.print("Testing conditional")
    txt.nl()
    if (counter >= max-iterations) {
        txt.print("Max iterations reached")
        txt.nl()
    } else if (counter > 5) {
        txt.print("Some iterations completed")
        txt.nl()
    } else {
        txt.print("Few iterations")
        txt.nl()
    }
    txt.print("Program complete")
    txt.nl()
}
}