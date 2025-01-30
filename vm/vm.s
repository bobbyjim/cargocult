    .segment "CODE"
    .org $1000    ; Start of program (standard for cc65)

R0 = $02
R1 = $04
R2 = $06
R3 = $08
R4 = $0A
R5 = $0C
R6 = $0E
R7 = $10
PC = $12            ; R8
SP = $14            ; R9L
FLAGS = SP+1        ; R9H

KERNAL_CHROUT = $FFD2

    .global _start
_start:
    LDA #<(test_program)
    STA PC
    LDA #>(test_program)
    STA PC+1

interpreter:
    LDA #58               ; ':'
    JSR $FFD2
    LDA (PC)              ; Fetch opcode byte
    JSR $FFD2             ; Print the opcode index "letter"    
    ASL                   ; Multiply by 2
    TAX                   ; Move index to X register (index into jump table)
    INC PC                ; Move to the next opcode   
    JMP (opcode_table, X) ; Jump to the address stored at opcode_table[X]

opcode_table:
    .addr 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0   ; 0-15
    .addr 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0   ; 16-31
    .addr 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0   ; 32-47
    .addr 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0   ; 48-63
    .addr halt_program    ; 64 HCF
    .addr pad_opcode      ; 65 PAD
    .addr say_opcode      ; 66 SAY
    .addr shutdown_opcode ; 67 SHD
    .addr jmp_opcode      ; 68 JMP

halt_program:
    RTS                ; Halt program (could be an infinite loop or HCF operation)

pad_opcode:            ; No operation (do nothing)
    JMP interpreter

say_opcode:
    ; Print character param at PC
    LDA (PC)
    JSR KERNAL_CHROUT
    INC PC
    JMP interpreter

shutdown_opcode:
    RTS                ; Soft reset or shutdown (could be a "JMP $FFFF" for system halt)

jmp_opcode:
    LDA (PC)           ; read low byte param
    TAX                ; and store it in X
    INC PC             ; next byte in input
    LDA (PC)           ; read hi byte param
    TAY                ; and store it in Y
    STX PC             ; store that in PC
    STY PC+1           ; goes into PC+1    
    JMP interpreter

print_char:
    ; Print character in A register
    JSR KERNAL_CHROUT 
    JMP interpreter

test_program:
    .byte 68                    ; D:JMP 
       .addr test_program_cont
test_program_cont:    
    .byte 66                    ; B:SAY
        .byte 66                ; 'B'
    .byte 66                    ; B:SAY
        .byte 65                ; 'A'
    .byte 65                    ; A:PAD
    .byte 64                    ; @:HCF

