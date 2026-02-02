# Xenober16 Language Reference
**Complete guide to writing Xenober16 programs**

Version 1.0 - January 2026

---

## Table of Contents
1. [Introduction](#introduction)
2. [Program Structure](#program-structure)
3. [Basic Syntax](#basic-syntax)
4. [Data Types](#data-types)
5. [Variables and Constants](#variables-and-constants)
6. [Expressions and Operators](#expressions-and-operators)
7. [Control Flow](#control-flow)
8. [Procedures](#procedures)
9. [Memory Management](#memory-management)
10. [Module System](#module-system)
11. [Complete Examples](#complete-examples)

---

## Introduction

Xenober16 is a retro-inspired systems programming language combining:
- **Oberon-07** syntax (clean, structured)
- **COBOL** division-based organization (readable, self-documenting)
- **6502/65C02** target platforms (C64, Commander X16)

**Philosophy**: Transpile to backends (Prog8, cc65) rather than compiling directly.

---

## Program Structure

Every Xenober16 program consists of **divisions** in this order:

```
MODULE IDENTIFICATION DIVISION.          [REQUIRED]
    MODULE-ID. ProgramName.
    AUTHOR. Your Name.
    DESCRIPTION. What this does.

IMPORT DIVISION.                         [OPTIONAL]
    - ModuleName;

CONSTANTS DIVISION.                      [OPTIONAL]
    constantName := value;

MEMORY DIVISION.                         [OPTIONAL]
    AREA areaName RAM($address) SIZE bytes;

DATA DIVISION.                           [OPTIONAL]
    variableName: type;

PROCEDURE DIVISION.                      [OPTIONAL]
    PROC procedureName(params)
        ...
    END

MAIN DIVISION.                           [REQUIRED if no PROCEDURE]
    ...

MODULE END.                              [REQUIRED]
```

### Minimal Valid Program

```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. HelloWorld.

MAIN DIVISION.
    SAY "Hello, World!";

MODULE END.
```

---

## Basic Syntax

### Comments

**Standard style** (familiar to most programmers):
```xenober
// This is a comment
// Comments start with // and continue to end of line
x := 42;  // You can also put them at the end of lines
```

**Retro style** (tractor-feed aesthetic):
```xenober
|o This is a comment
|o The |o looks like holes in tractor-feed paper
|o Both styles work the same way
```

Use whichever style fits your aesthetic preference!

### Identifiers
- Start with letter or underscore: `a-z A-Z _`
- Continue with letters, digits, underscore: `a-z A-Z 0-9 _`
- Examples: `myVar`, `total_sum`, `Player1`

### Literals
```xenober
42          |* Decimal number
$FF         |* Hexadecimal (255)
$0400       |* Hex address (1024)
"text"      |* String literal
```

### Statement Terminator
**All statements end with semicolon `;`**

```xenober
x := 42;
SAY "Done";
```

---

## Data Types

### Integer Types
| Type | Size | Range | Signed |
|------|------|-------|--------|
| `uint8` | 1 byte | 0-255 | No |
| `uint16` | 2 bytes | 0-65535 | No |
| `int8` | 1 byte | -128-127 | Yes |
| `int16` | 2 bytes | -32768-32767 | Yes |
| `char` | 1 byte | 0-255 | No |

### String Type
```xenober
message: string;
```

### Arrays

Arrays are fully supported with fixed compile-time sizes:

```xenober
DATA DIVISION.
    buffer: ARRAY[100] OF uint8;
    scores: ARRAY[10] OF uint16;
    values: ARRAY[256] OF uint8;

MAIN DIVISION.
    buffer[0] := 42;
    buffer[10] := buffer[0] + 5;
    SAY buffer[10];
```

**Features:**
- Fixed-size arrays allocated at compile time
- Supports indexing with `array[index]` syntax
- Can hold any data type (uint8, uint16, etc.)
- Passed by reference to procedures

### Records (Future)
```xenober
player: RECORD
    x: uint8;
    y: uint8;
    score: uint16;
END RECORD;
```

---

## Variables and Constants

### DATA DIVISION - Variables

**Syntax**: `name: type;`

```xenober
DATA DIVISION.
    x: uint8;
    y: uint8;
    total: uint16;
    message: string;
    counter: int8;
```

### CONSTANTS DIVISION

**Syntax**: `name: type = value;`

```xenober
CONSTANTS DIVISION.
    MAX_PLAYERS: uint8 = 4;
    SCREEN_WIDTH: uint8 = 40;
    SCREEN_HEIGHT: uint8 = 25;
    COLOR_WHITE: uint8 = 1;
    GREETING: string = "Hello";
```

Constants can reference other constants:
```xenober
CONSTANTS DIVISION.
    SCREEN_SIZE: uint16 = 1000;
    LAST_INDEX: uint16 = SCREEN_SIZE - 1;
```

### Enumerations

Enumerations are declared in the `ENUM DIVISION` and automatically converted to constants:

```xenober
DATA DIVISION.
    value: uint8;

ENUM DIVISION.
    ENUM Color
        RED = 0,
        GREEN = 1,
        BLUE = 2,
        YELLOW = 3
    END ENUM;

MAIN DIVISION.
    value := RED;  |* RED is now 0
    value := BLUE; |* BLUE is now 2
    SAY value;
```

**Notes:**
- Enum values are stored as integer constants
- Explicit values (like `RED = 0`) are supported
- If you omit a value, it auto-increments from the previous one
- Enum members become available as constants for use anywhere in your code

---

## Expressions and Operators

### Assignment
**Syntax**: `variable := expression;`

```xenober
x := 42;
y := x + 10;
total := x * y;
```

### Arithmetic Operators
```xenober
a + b       |o  Addition
a - b       |o  Subtraction
a * b       |o  Multiplication
a / b       |o  Division (integer)
a DIV b     |o  Division (explicit)
a MOD b     |o  Modulo (remainder)
```

### Comparison Operators
```xenober
a = b       |o  Equal
a <> b      |o  Not equal
a < b       |o  Less than
a <= b      |o  Less or equal
a > b       |o  Greater than
a >= b      |o  Greater or equal
```

### String Concatenation
```xenober
result := "Hello" & " " & "World";
```

### Operator Precedence (highest to lowest)
1. `()` Parentheses
2. `-` Unary negation
3. `*` `/` `MOD` `DIV`
4. `+` `-` `&`
5. `=` `<>` `<` `<=` `>` `>=`

---

## Control Flow

### IF Statement

**Simple IF**:
```xenober
IF condition THEN
    |* statements
END
```

**IF-ELSE**:
```xenober
IF x > 10 THEN
    SAY "Greater than 10";
ELSE
    SAY "10 or less";
END
```

**IF-ELSIF-ELSE**:
```xenober
IF score < 10 THEN
    SAY "Low score";
ELSIF score < 20 THEN
    SAY "Medium score";
ELSIF score < 30 THEN
    SAY "High score";
ELSE
    SAY "Excellent!";
END
```

### WHILE Loop

```xenober
WHILE condition DO
    |* statements
END
```

Example:
```xenober
counter := 0;
WHILE counter < 10 DO
    SAY counter;
    counter := counter + 1;
END
```

### REPEAT-UNTIL Loop

```xenober
REPEAT
    |* statements (always execute at least once)
UNTIL condition
```

Example:
```xenober
counter := 0;
REPEAT
    SAY counter;
    counter := counter + 1;
UNTIL counter = 10
```

### FOR Loop

**Syntax**: `FOR variable := start TO end DO ... END`

```xenober
FOR i := 0 TO 9 DO
    SAY i;
END
```

**With STEP**:
```xenober
FOR i := 0 TO 100 BY 10 DO
    SAY i;  |* Prints 0, 10, 20, ... 100
END
```

**Descending**:
```xenober
FOR i := 10 TO 0 BY -1 DO
    SAY i;  |* Counts down
END
```

### CASE Statement

**Syntax**:
```xenober
CASE expression OF
    | value1:
        |* statements
    | value2:
        |* statements
    ELSE
        |* default statements
END
```

**Example with single values**:
```xenober
CASE day OF
    | 0:
        SAY "Sunday";
    | 1:
        SAY "Monday";
    | 2:
        SAY "Tuesday";
    | 6, 7:
        SAY "Weekend";
    ELSE
        SAY "Weekday";
END
```

**Example with ranges**:
```xenober
CASE score OF
    | 0..10:
        SAY "Low";
    | 11..20:
        SAY "Medium";
    | 21..30:
        SAY "High";
    ELSE
        SAY "Out of range";
END
```

---

## Procedures

### Defining Procedures

**Syntax**:
```xenober
PROCEDURE DIVISION.
    PROC procedureName(param1: type1, param2: type2)
        |* statements
    END
```

**Example without parameters**:
```xenober
PROCEDURE DIVISION.
    PROC greet()
        SAY "Hello!";
        SAY "Welcome to Xenober16";
    END
```

**Example with parameters**:
```xenober
PROCEDURE DIVISION.
    PROC add(a: uint8, b: uint8)
        result: uint8;
        result := a + b;
        SAY result;
    END
```

### Calling Procedures

```xenober
MAIN DIVISION.
    greet();
    add(10, 20);
```

### Return Values

```xenober
PROCEDURE DIVISION.
    PROC calculate(x: uint8)
        RETURN x * 2;
    END

MAIN DIVISION.
    result := calculate(21);
    SAY result;  |* Prints 42
```

### Local Variables

Declare variables inside procedures:
```xenober
PROC calculate(x: uint8, y: uint8)
    temp: uint8;
    result: uint16;
    
    temp := x + y;
    result := temp * 2;
    RETURN result;
END
```

---

## Memory Management

### Memory Areas (MEMORY DIVISION)

Define memory-mapped regions for direct hardware access:

```xenober
MEMORY DIVISION.
    AREA screen RAM($0400) SIZE 1000;
    AREA colorram RAM($D800) SIZE 1000;
    AREA sprites BANK(1, $A000) SIZE 64;
```

### Accessing Memory Areas

Use memory area names like transparent arrays:

```xenober
DATA DIVISION.
    index: uint8;

MAIN DIVISION.
    screen[0] := 65;       |* Write 'A' to first screen position
    colorram[0] := 14;     |* Set color attribute
    
    FOR index := 0 TO 999 DO
        screen[index] := 32;   |* Fill screen with spaces
    END
    
    SAY screen[40];        |* Read from screen
```

**Memory area syntax:**
- `AREA name RAM($address) SIZE bytes;` - Direct RAM access
- `AREA name BANK(n, $address) SIZE bytes;` - Banked memory
- Use names like regular arrays: `name[index]`

### Direct Memory Access

For raw memory access without declaring areas:

**Read from address**:
```xenober
value := RAM[$D020];       |* Read border color
value := BANK(1)[$C000];   |* Read from bank 1
```

**Write to address**:
```xenober
RAM[$D020] := 0;           |* Set border black
BANK(1)[$A000] := 255;     |* Write to banked memory
```

---

## Module System

### Module Identification

```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. MyModule.
    AUTHOR. Your Name.
    DESCRIPTION. Module purpose.
```

### Importing Modules

```xenober
IMPORT DIVISION.
    - ModuleName;
    - AnotherModule;
```

**With alias**:
```xenober
IMPORT DIVISION.
    - LongModuleName AS LMN;
```

### Calling Imported Functions

```xenober
MAIN DIVISION.
    ModuleName.functionName();
    LMN.otherFunction(42);
```

### Module Parameters

Define template parameters for your module (similar to generics):

```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. SpriteEngine.
    PARAMETERS: max_sprites: uint8 := 8, sprite_size: uint8 := 64, enable_collision: uint8 := 1;
    AUTHOR. Game Dev.
```

Parameters become available as constants throughout your module:
- Can be used in array declarations: `sprites: ARRAY[max_sprites] OF Sprite;`
- Can be used in expressions: `FOR i := 0 TO max_sprites - 1 DO ... END`
- Are displayed during interpretation with their resolved values

---

## Complete Examples

### Example 1: Counter Program

```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. Counter.
    AUTHOR. Student.
    DESCRIPTION. Counts from 0 to 10.

DATA DIVISION.
    i: uint8;

MAIN DIVISION.
    FOR i := 0 TO 10 DO
        SAY i;
    END
    SAY "Done!";

MODULE END.
```

### Example 2: Screen Clearing

```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. ScreenClear.
    DESCRIPTION. Clears the C64 screen.

MEMORY DIVISION.
    AREA screen RAM($0400) SIZE 1000;

CONSTANTS DIVISION.
    SPACE := 32;
    SCREEN_SIZE := 1000;

DATA DIVISION.
    i: uint16;

MAIN DIVISION.
    FOR i := 0 TO SCREEN_SIZE - 1 DO
        @screen[i] := SPACE;
    END

MODULE END.
```

### Example 3: Color Cycling

```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. ColorCycle.
    DESCRIPTION. Cycles border colors.

CONSTANTS DIVISION.
    BORDER_REG := $D020;
    MAX_COLOR := 15;

DATA DIVISION.
    color: uint8;
    delay: uint16;
    j: uint16;

MAIN DIVISION.
    color := 0;
    
    REPEAT
        @(BORDER_REG) := color;
        
        |* Delay loop
        FOR j := 0 TO 1000 DO
            |* Just waste time
        END
        
        color := color + 1;
        IF color > MAX_COLOR THEN
            color := 0;
        END
    UNTIL color = 0

MODULE END.
```

### Example 4: Procedures and Parameters

```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. Calculator.
    DESCRIPTION. Simple calculator with procedures.

DATA DIVISION.
    x: uint8;
    y: uint8;
    result: uint16;

PROCEDURE DIVISION.
    PROC add(a: uint8, b: uint8)
        result := a + b;
        SAY "Sum:";
        SAY result;
    END
    
    PROC multiply(a: uint8, b: uint8)
        result := a * b;
        SAY "Product:";
        SAY result;
    END
    
    PROC isEven(n: uint8)
        IF n MOD 2 = 0 THEN
            SAY "Even";
        ELSE
            SAY "Odd";
        END
    END

MAIN DIVISION.
    x := 10;
    y := 5;
    
    add(x, y);
    multiply(x, y);
    isEven(x);
    isEven(7);

MODULE END.
```

### Example 5: Nested Loops and Memory

```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. ScreenPattern.
    DESCRIPTION. Draws a pattern on screen.

MEMORY DIVISION.
    AREA screen RAM($0400) SIZE 1000;
    AREA colors RAM($D800) SIZE 1000;

CONSTANTS DIVISION.
    SCREEN_WIDTH := 40;
    SCREEN_HEIGHT := 25;

DATA DIVISION.
    row: uint8;
    col: uint8;
    pos: uint16;
    pattern: uint8;

MAIN DIVISION.
    pattern := 160;  |* Checkerboard pattern
    
    FOR row := 0 TO SCREEN_HEIGHT - 1 DO
        FOR col := 0 TO SCREEN_WIDTH - 1 DO
            pos := row * SCREEN_WIDTH + col;
            @screen[pos] := pattern;
            @colors[pos] := col MOD 16;
        END
    END
    
    SAY "Pattern complete!";

MODULE END.
```

---

## Quick Reference Card

### Structure Template
```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. ProgramName.
    AUTHOR. Your Name.

DATA DIVISION.
    |* variables here

PROCEDURE DIVISION.
    |* procedures here

MAIN DIVISION.
    |* main code here

MODULE END.
```

### Common Patterns

**Print and loop**:
```xenober
SAY "Message";
FOR i := 0 TO 9 DO
    SAY i;
END
```

**Conditional**:
```xenober
IF x > 0 THEN
    SAY "Positive";
ELSIF x < 0 THEN
    SAY "Negative";
ELSE
    SAY "Zero";
END
```

**Memory write**:
```xenober
@screen[index] := value;
@($D020) := color;
```

### Keywords List
```
MODULE, IDENTIFICATION, DIVISION, END
IMPORT, CONSTANTS, MEMORY, DATA, PROCEDURE, MAIN
AREA, RAM, BANK, SIZE, AT
ENUM
PROC, RETURN
IF, THEN, ELSIF, ELSE
FOR, TO, BY, DO
WHILE, REPEAT, UNTIL
CASE, OF
SAY, ECHO
uint8, uint16, int8, int16, char, string
ARRAY, OF, RECORD
DIV, MOD
```

### Operators
```
:=    Assignment
+     Addition
-     Subtraction
*     Multiplication
/     Division
DIV   Integer division
MOD   Modulo
=     Equal
<>    Not equal
<     Less than
<=    Less or equal
>     Greater than
>=    Greater or equal
&     String concat
```

---

## Tips and Best Practices

1. **Always end statements with `;`** - Most common syntax error
2. **Use descriptive names** - `playerScore` not `ps`
3. **Group related code in procedures** - Keep MAIN DIVISION clean
4. **Use constants for magic numbers** - `MAX_LIVES := 3` not just `3`
5. **Comment your memory areas** - Document what each area is for
6. **Test incrementally** - Use the interpreter before transpiling

---

## Error Messages to Expect

**"Parser failed"** - Syntax error, check semicolons and keywords
**"Undefined variable"** - Variable not declared in DATA DIVISION
**"Undefined procedure"** - Procedure called but not defined
**"Undefined memory area"** - Memory area referenced but not declared
**"Type mismatch"** - Check your variable types

---

This reference should enable anyone to write Xenober16 code without seeing other examples. For more complex examples, see the `test-files/` directory.
