; Transpiled from Xenober16 to Prog8
; Module: MemoryAreaTest
; Author: Rob
; Description: Tests memory area declarations and direct access patterns.

memoryareatest {











&uword screen = $400  ; size: 1000
&uword sprites = $800  ; size: 1024
&uword vic_regs = $D000  ; size: 47
&uword color_ram = $D800  ; size: 1000
; Memory area buffer in BANK 1 at $A000 (size: 8192)
&uword buffer = $A000  ; bank: 1











sub start() {
    txt.print("Testing memory area access")
    txt.nl()
    txt.print("Clearing screen area")
    txt.nl()
    for i in 0 to 40 {
        screen[i] = 32
    }
    txt.print("Setting sprite data")
    txt.nl()
    sprites[0] = 255
    sprites[1] = 129
    sprites[2] = 255
    txt.print("Configuring VIC registers")
    txt.nl()
    vic_regs[32] = 14
    txt.print("Testing implicit RAM access")
    txt.nl()
    @(53280) = 6
    value = @(56321)
    txt.print("Testing banked memory")
    txt.nl()
    buffer[0] = 72
    buffer[1] = 101
    buffer[2] = 108
    txt.print("Direct bank access")
    txt.nl()
    @(1:41216) = 42
    txt.print("Memory area test complete")
    txt.nl()
}
}