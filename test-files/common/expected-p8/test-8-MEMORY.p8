; Transpiled from Xenober16 to Prog8
; Module: MemoryTest
; Author: Rob
; Description: Tests MEMORY DIVISION with AREA declarations.

memorytest {











&uword lowram = $400  ; size: 1024
; Memory area hiram in BANK 1 at $A000 (size: 8192)
&uword hiram = $A000  ; bank: 1
; Memory area vera-data in BANK 0 at $9F00 (size: 256)
&uword vera-data = $9F00  ; bank: 0











sub start() {
    txt.print("Memory areas defined")
    txt.nl()
    buffer-ptr = 1024
    txt.print(buffer-ptr)
    txt.nl()
    data-byte = 42
    txt.print(data-byte)
    txt.nl()
}
}