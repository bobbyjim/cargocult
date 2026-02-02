; Transpiled from Xenober16 to Prog8
; Module: SpriteEngine
; Author: Rob
; Description: AKA generic parameters or template parameters.

spriteengine {







const uint8  max_sprites = 8
const uint8  sprite_size = 64
const uint8  enable_collision = 1











sub init() {
    for i in 0 to (max_sprites - 1) {
        sprites.size = sprite_size
    }
}