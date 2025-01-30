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
    LDA #<(test_program)  ; test program
    STA PC
    LDA #>(test_program)
    STA PC+1
    BRA interpreter       ; ok let's run the test

interpreter:
    LDA #58               ; ':'
    JSR $FFD2
    LDA (PC)              ; Fetch opcode byte
    JSR $FFD2             ; Print the opcode index "letter"    
    ASL                   ; Multiply by 2
    TAX                   ; Move index to X register (index into jump table)
    INC PC                ; Move to the next opcode   
    JMP (opcode_table, X) ; Jump to the address stored at opcode_table[X]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HCF = 64                ;
PAD = 65                ;           HERE'S ALL OUR OPCODES
SAY = 66                ;
SHD = 67                ;
JPA = 68                ;
JPZ = 69                ;
JNZ = 70                ;
ADD = 71                ;
SUB = 72                ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

say_opcode:
    ; Print character param at PC
    LDA (PC)           ; read param
    INC PC             ; consume param
    JSR KERNAL_CHROUT
pad_opcode:            ; No operation (do nothing)
    BRA interpreter

jpa_opcode:
    LDA (PC)           ; read low byte param
    INC PC             ; consume param
    TAX                ; and store it in X
    LDA (PC)           ; read hi byte param
    INC PC             ; consume param
    TAY                ; and store it in Y
    STX PC             ; store that in PC
    STY PC+1           ; goes into PC+1    
    BRA interpreter

; something wrong with it!!!
jpz_opcode:
    BNE interpreter    ; If Zero flag is not set, skip
    BRA jpa_opcode     ; continue processing

jnz_opcode:
    BEQ interpreter    ; If Zero flag is set, skip
    BRA jpa_opcode     ; continue processing

;
;   ADD P1 + P2 -> A
;
add_opcode:
    LDA (PC)           ; load operand from memory
    INC PC             ; consume param
    CLC                ; clear the carry flag
    ADC (PC)           ; add the next byte 
    INC PC             ; consume param
    STA R0             ; for inspection
    BRA interpreter    ; continue processing

; UNTESTED
;
;   SUB P1 - P2 -> A
;
sub_opcode:
    LDA (PC)           ; load operand from memory
    INC PC             ; consume param
    SEC                ; set the carry flag for subtraction
    SBC (PC)           ; subtract the next byte 
    INC PC             ; consume param
    STA R1             ; for inspection
    BRA interpreter    ; continue processing

halt_program:
    RTS                ; Halt program (could be an infinite loop or HCF operation)

shutdown_opcode:
    RTS                ; Soft reset or shutdown (could be a "JMP $FFFF" for system halt)

opcode_table:
    .addr 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0   ; 0-15
    .addr 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0   ; 16-31
    .addr 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0   ; 32-47
    .addr 0, 0, 0, 0, 0, 0, 0, 0,   0, 0, 0, 0, 0, 0, 0, 0   ; 48-63
    .addr halt_program    ; 64 HCF
    .addr pad_opcode      ; 65 PAD
    .addr say_opcode      ; 66 SAY
    .addr shutdown_opcode ; 67 SHD
    .addr jpa_opcode      ; 68 JPA
    .addr jpz_opcode      ; 69 JPZ
    .addr jnz_opcode      ; 70 JNZ
    .addr add_opcode      ; 71 ADD
    .addr sub_opcode      ; 72 SUB

test_program:
    .byte ADD, 3, 1             ; :G
    .byte SUB, 3, 1             ; :H
    .byte JPZ                   ; 
       .addr test_program_cont
test_program_cont:    
    .byte SAY, 66               ; :BB
    .byte SAY, 65               ; :BA
    .byte PAD                   ; :A
    .byte HCF                   ; :@
