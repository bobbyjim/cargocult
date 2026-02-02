# Xenober16 Quick Reference - January 2026

## Program Structure
```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. ProgramName.
    PARAMETERS: param1: uint8 := 10;
    AUTHOR. Your Name.
    DESCRIPTION. What it does.

MEMORY DIVISION.
    AREA screen RAM($0400) SIZE 1000;

DATA DIVISION.
    x: uint8;
    scores: ARRAY[10] OF uint8;

ENUM DIVISION.
    ENUM Color
        RED = 0,
        GREEN = 1,
        BLUE = 2
    END ENUM;

PROCEDURE DIVISION.
    PROC myProc(value: uint8)
        SAY value;
    END

MAIN DIVISION.
    x := 42;
    myProc(x);

MODULE END.
```

## Data Types
- `uint8`, `uint16`, `int8`, `int16` - Integer types
- `char` - Single character
- `string` - String literals
- `ARRAY[size] OF type` - Fixed arrays

## Variables
```xenober
DATA DIVISION.
    count: uint8;
    buffer: ARRAY[256] OF uint8;
    value: uint16;
```

## Constants
```xenober
CONSTANTS DIVISION.
    MAX_SIZE := 256;
    BUFFER_SIZE: uint16 := 1024;
    GREETING := "Hello";
```

## Arrays
```xenober
scores: ARRAY[10] OF uint8;
scores[0] := 100;
scores[5] := scores[0] + 50;
```

## Memory Areas
```xenober
MEMORY DIVISION.
    AREA screen RAM($0400) SIZE 1000;

MAIN DIVISION.
    screen[0] := 65;        |* Write to screen
    FOR i := 0 TO 999 DO
        screen[i] := 32;
    END
```

## Direct Memory Access
```xenober
RAM[$D020] := 0;            |* Set border color
BANK(1)[$A000] := 255;      |* Write to bank 1
value := RAM[$D021];        |* Read from register
```

## Module Parameters
```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. Engine.
    PARAMETERS: 
        MAX_ITEMS: uint8 := 8,
        SIZE: uint8 := 64;

DATA DIVISION.
    items: ARRAY[MAX_ITEMS] OF uint8;
```

## ENUMs
```xenober
ENUM DIVISION.
    ENUM Mode
        DISABLED = 0,
        NORMAL = 1,
        ADVANCED
    END ENUM;
```

## Procedures
```xenober
PROC greet(name: uint8, age: uint8)
    SAY "Hello";
    SAY name;
    SAY age;
END

MAIN DIVISION.
    greet(42, 25);
```

## Control Flow

### IF Statement
```xenober
IF x = 5 THEN
    SAY "Five";
ELSIF x > 10 THEN
    SAY "Big";
ELSE
    SAY "Other";
END
```

### WHILE Loop
```xenober
WHILE x < 100 DO
    x := x + 1;
    SAY x;
END
```

### FOR Loop
```xenober
FOR i := 0 TO 10 DO
    SAY i;
END

FOR i := 100 TO 0 BY -1 DO
    countdown[i] := i;
END
```

### CASE Statement
```xenober
CASE color OF
    RED:
        SAY "Red";
    GREEN:
        SAY "Green";
    ELSE
        SAY "Other";
END
```

## Operators
- Arithmetic: `+`, `-`, `*`, `/`, `MOD`
- Comparison: `=`, `<>`, `<`, `<=`, `>`, `>=`
- Logical: `AND`, `OR`

## Built-in Functions
- `SAY value` - Print value
- `ECHO value` - Echo value
- `RETURN value` - Return from procedure

## Comments
```xenober
|* This is a comment *|
|o Block comment line
|o Another comment line
```

## Example Programs

### Counter
```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. Counter.

DATA DIVISION.
    i: uint8;

MAIN DIVISION.
    FOR i := 0 TO 10 DO
        SAY i;
    END

MODULE END.
```

### Screen Fill
```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. ScreenFill.

MEMORY DIVISION.
    AREA screen RAM($0400) SIZE 1000;

DATA DIVISION.
    i: uint16;

MAIN DIVISION.
    FOR i := 0 TO 999 DO
        screen[i] := 32;
    END

MODULE END.
```

---

**For more details, see:**
- `LANGUAGE-REFERENCE.md` - Complete language guide
- `README.md` - Project overview
- `SESSION_SUMMARY.md` - Implementation details
- Test files in `test-files/` - Working examples
