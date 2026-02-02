; Transpiled from Xenober16 to Prog8
; Module: BitfieldTest
; Author: Rob
; Description: Tests bitfield-like operations with simple types.

bitfieldtest {























sub start() {
    txt.print("Testing bitfield operations")
    txt.nl()
    flags = 0
    flags = (flags + 1)
    status = flags
    txt.print("Bitfield values set")
    txt.nl()
    sprite_attr = 0
    sprite_attr = (sprite_attr + 64)
    txt.print("Sprite attributes configured")
    txt.nl()
    txt.print("Bitfield test complete")
    txt.nl()
}
}