; Transpiled from Xenober16 to Prog8
; Module: ComprehensiveTest
; Author: Rob
; Description: Combines all new features - FOR loops and memory areas.

comprehensivetest {











&uword screen = $400  ; size: 1000
&uword color_ram = $D800  ; size: 1000







sub clear_screen() {
    for i in 0 to 999 {
        screen[i] = 32
        color_ram[i] = 14
    }
}



sub start() {
    txt.print("Comprehensive feature test")
    txt.nl()
    txt.print("Clearing screen with FOR loop")
    txt.nl()
    clear_screen()
    txt.print("Writing pattern to screen")
    txt.nl()
    color = 1
    for i in 0 to 24 {
        for j in 0 to 39 {
            screen[((i * 40) + j)] = 160
            color_ram[((i * 40) + j)] = color
        }
        color = (color + 1)
        if (color > 15) {
            color = 1
        }
    }
    txt.print("All features tested successfully")
    txt.nl()
}
}