# xenober-16
An easy-to-parse procedural programming language.

Its parser is written in Raku.

# 1. Project Goals
- **Tailored for X16 Programming**: Create a domain-specific language (DSL) tailored for the Commander X16 platform.
- **Learn from Oberon**: Unambiguous syntax means easy to parse.
- **Learn from COBOL**: Program divisions flattens the grammar.

# Fuzzy Definition
Oberon is the starting point, due to its unambiguous and therefore simple parsing structure.
COBOL then adds structure, allowing us to reduce keywords, simplify declarations, and perhaps we can get
banked memory referencing (nearly) for free.

# No Need For These Ever
* No Memory allocation.
* No Real number support.

# MVP

* IDENTIFICATION DIVISION.
* PROGRAM-ID. <name>.
* DATA DIVISION.
* WORKING-STORAGE SECTION.
* UINT8 declarations.
* PROCEDURE DIVISION.
* assignment with := 
* SAY
* Add, Subtract, Multiply, Divide ops.
* END PROGRAM.

# Version 2

* PROC 
* control flow
* string
* Records (structures)
* REFAT or equivalent

# Version 3

* Named parameter lists for procs.
* Five more types supported: int8_t, int16_t, int32_t, uint16_t, uint32_t.
* Bitfields supported inside Records.

# Version 4

* Fixed-point type: fixed8_8_t.

