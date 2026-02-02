# Xenober16 to Prog8 Transpiler Examples

## Example 1: Simple FOR Loop with Screen Memory

### Xenober16 Source (test-14-comprehensive-2.xen):
```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. ComprehensiveTest.
    AUTHOR. Rob.
    DESCRIPTION. Combines all new features - FOR loops and memory areas.

MEMORY DIVISION.
    AREA screen RAM($0400) SIZE 1000;
    AREA color_ram RAM($D800) SIZE 1000;

DATA DIVISION.
    i: uint8;
    j: uint8;
    color: uint8;

PROCEDURE DIVISION.
    PROC clear_screen()
        FOR i := 0 TO 999 DO
            @screen[i] := 32;
            @color_ram[i] := 14;
        END
    END

MAIN DIVISION.
    SAY "Comprehensive feature test";
    clear_screen();
    
    color := 1;
    FOR i := 0 TO 24 DO
        FOR j := 0 TO 39 DO
            @screen[i * 40 + j] := 160;
            @color_ram[i * 40 + j] := color;
        END
        color := color + 1;
        IF color > 15 THEN
            color := 1;
        END
    END

MODULE END.
```

### Generated Prog8:
```prog8
; Transpiled from Xenober16 to Prog8
; Module: ComprehensiveTest
; Author: Rob
; Description: Combines all new features - FOR loops and memory areas.

comprehensivetest {

    &uword screen = $0400  ; size: 1000
    &uword color_ram = $D800  ; size: 1000

    ubyte i
    ubyte j
    ubyte color

    sub clear_screen() {
        for i in 0 to 999 {
            screen[i] = 32
            color_ram[i] = 14
        }
    }

    sub start() {
        txt.print("Comprehensive feature test")
        txt.nl()
        clear_screen()
        
        color = 1
        for i in 0 to 24 {
            for j in 0 to 39 {
                screen[((i * 40) + j)] = 160
                color_ram[((i * 40) + j)] = color
            }
            color = (color + 1)
            if (color > 15) {
                color = 1
            }
        }
    }
}
```

## Example 2: Procedures with Parameters

### Xenober16 Source (test-6-PROC.xen):
```xenober
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. ProcedureTest.

PROCEDURE DIVISION.
    PROC greet(name: uint8)
        SAY "Hello";
        SAY name;
    END

    PROC add(a: uint8, b: uint8)
        result := a + b;
        SAY result;
    END

MAIN DIVISION.
    x := 10;
    y := 5;
    greet(42);
    add(x, y);
    add(100, 50);

MODULE END.
```

### Generated Prog8:
```prog8
; Transpiled from Xenober16 to Prog8
; Module: ProcedureTest

proceduretest {

    sub greet(ubyte name) {
        txt.print("Hello")
        txt.nl()
        txt.print(name)
        txt.nl()
    }

    sub add(ubyte a, ubyte b) {
        result = (a + b)
        txt.print(result)
        txt.nl()
    }

    sub start() {
        x = 10
        y = 5
        greet(42)
        add(x, y)
        add(100, 50)
    }
}
```

## Example 3: CASE Statement with Ranges

### Xenober16 Source (test-5-CASE.xen excerpt):
```xenober
MAIN DIVISION.
    score := 25;
    SAY "Score range test";
    
    CASE score OF
        | 1..10:
            SAY "Low range";
        | 11..20:
            SAY "Medium-low range";
        | 21..30:
            SAY "Medium range";
        | 31..40, 50:
            SAY "High range or exactly 50";
        ELSE
            SAY "Out of range";
    END
```

### Generated Prog8:
```prog8
    sub start() {
        score = 25
        txt.print("Score range test")
        txt.nl()
        
        when score {
            1..10 -> {
                txt.print("Low range")
                txt.nl()
            }
            11..20 -> {
                txt.print("Medium-low range")
                txt.nl()
            }
            21..30 -> {
                txt.print("Medium range")
                txt.nl()
            }
            31..40 -> {
                txt.print("High range or exactly 50")
                txt.nl()
            }
            50 -> {
                txt.print("High range or exactly 50")
                txt.nl()
            }
            else -> {
                txt.print("Out of range")
                txt.nl()
            }
        }
    }
```

## Key Translation Patterns

| Xenober16 | Prog8 | Notes |
|-----------|-------|-------|
| `MODULE-ID. MyModule` | `mymodule {` | Lowercase conversion |
| `uint8` | `ubyte` | Unsigned 8-bit |
| `uint16` | `uword` | Unsigned 16-bit |
| `SAY "text"` | `txt.print("text")` + `txt.nl()` | Print with newline |
| `ECHO "text"` | `txt.print("text")` | Print without newline |
| `FOR i := 0 TO 10` | `for i in 0 to 10` | Range iteration |
| `WHILE x < 10` | `while (x < 10)` | Conditional loop |
| `IF x = 5 THEN` | `if (x == 5) {` | Equality operator |
| `x <> 5` | `(x != 5)` | Inequality operator |
| `x MOD 5` | `(x % 5)` | Modulo operator |
| `CASE x OF \| val:` | `when x { val -> {` | Pattern matching |
| `AREA screen RAM($0400)` | `&uword screen = $0400` | Memory-mapped pointer |
| `@screen[i]` | `screen[i]` | Array access via pointer |
| `PROC myproc(x: uint8)` | `sub myproc(ubyte x)` | Subroutine definition |

## Features Supported

✅ All basic data types (uint8, uint16, int8, int16)
✅ Variables and constants
✅ Binary operators (+, -, *, /, MOD, =, <>, <, >, <=, >=)
✅ Control flow (IF/ELSIF/ELSE, WHILE, REPEAT/UNTIL, FOR, CASE)
✅ Procedures with parameters
✅ Memory areas (RAM/BANK)
✅ Direct memory access
✅ Module metadata (author, description)
✅ Enumerations
✅ Module parameters
✅ Imports (basic)

## Limitations & Future Work

⚠️ String concatenation operator `&` currently maps to `+` (may need refinement)
⚠️ Multi-module compilation not yet tested
⚠️ Record/struct types in progress
⚠️ Bitfield operations need verification in Prog8 context
