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

# CURRENT

* IDENTIFICATION DIVISION.
* PROGRAM-ID. <name>.

* DATA DIVISION.
* WORKING-STORAGE SECTION.
* INT8, INT16, INT32, UINT8, UINT16, UINT32, STRING declarations.

* PROCEDURE DIVISION.
* assignment with := 
* SAY
* Arithmetic binops with precedence (* / %) and (+ -)
* Compare binops < > <= >= == !=
* IF THEN ELSIF ELSE END

* END PROGRAM.

# TO BE DONE

* Compound conditions (&& ||) 
* Nested IFs
* WHILE
* REPEAT / UNTIL
* FOR
* CASE
* BANK-STORAGE SECTION for holding references to banked data
* Arrays
* PROC or function calls
* Named parameter lists for procs.
* Records (structures)
* Bitfields inside Records or a special type of Record.
* Fixed-point type: fixed8_8_t.
