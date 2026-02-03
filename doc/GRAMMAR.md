# XENOBER16 GRAMMAR - COMPLETE REFERENCE

## Overview
Xenober16 is a COBOL-inspired language targeting the Commodore 16 8-bit computer.
The grammar uses PEG (Parsing Expression Grammar) with Raku's Grammar system for deterministic parsing.

### Key Features
- **Comments**: `//` style line comments are supported throughout the code
- **Type System**: Builtin types (uint8, uint16, int8, int16, string, char, byte), arrays, pointers, records, and enums
- **Divisions**: Modular program structure with optional sections
- **Macros**: Both simple (value) macros and function-like (procedural) macros
- **Memory**: Direct memory access with RAM and BANK support
- **Control Flow**: IF/ELSIF/ELSE, WHILE, REPEAT/UNTIL, FOR, CASE statements
- **Functions**: FN definitions with parameters and return values

---

## PROGRAM STRUCTURE

```
Program → ProgramIdentificationDivision
           ImportDivision?
           ConstantsDivision?
           MemoryDivision?
           MacroDivision?
           DataDivision?
           EnumDivision?
           ProcedureDivision?
           MainDivision?
           "MODULE END."
```

---

## IDENTIFICATION DIVISION

```
ProgramIdentificationDivision → "MODULE IDENTIFICATION DIVISION."
                                ModuleId
                                ModuleParameters?
                                Author?
                                Description?
                                Purpose?

ModuleId → ("MODULE-ID." | "ID:") identifier "."
ModuleParameters → ("PARAMETERS" | "PARAMS:") ":" ParameterDeclList ";"
ParameterDeclList → ParameterDecl ("," ParameterDecl)*
ParameterDecl → identifier ":" Type (":=" Expression)?

Author → ("AUTHOR." | "WHO:" | "BY:") identifier "."
Description → ("DESCRIPTION." | "WHAT:" | "DESC:") <rest-of-line>
Purpose → ("PURPOSE." | "WHY:") <rest-of-line>
```

---

## IMPORT DIVISION

```
ImportDivision → "IMPORT DIVISION." Use+
Use → "-" identifier ";"
```

---

## CONSTANTS DIVISION

```
ConstantsDivision → "CONSTANTS DIVISION." ConstantDeclaration+

ConstantDeclaration → identifier
                      (
                          ":" Type "=" ConstantValue
                        | ":=" ConstantValue
                      )
                      ";"

ConstantValue → number | string
```

---

## MACRO DIVISION

The MACRO DIVISION supports two types of macros:

### 1. Function-like Macros (NEW)
Used for code generation with parameters and return types.

```
MacroDivision → "MACRO DIVISION." MacroDeclaration+

MacroDeclaration → FunctionLikeMacro | SimpleMacro

FunctionLikeMacro → "META" identifier "(" ParameterList? ")" ":" Type
                    "BEGIN"
                        Statement+
                    "END" identifier ";"

ParameterList → Parameter ("," Parameter)*
Parameter → identifier ":" Type
```

Example:
```
META clamp(value: uint8, min: uint8, max: uint8) : uint8
BEGIN
    IF value < min THEN
        RETURN min;
    END
    IF value > max THEN
        RETURN max;
    END
    RETURN value;
END clamp;
```

### 2. Simple Macros
Used for compile-time value substitution.

```
SimpleMacro → identifier ":" MacroType "IS" Expression ";"

MacroType → "int8" | "int16" | "byte" | "uint8" | "uint16" | "char" | "string"
```

Example:
```
MAX_SIZE: uint16 IS 1024;
```

---

## MEMORY DIVISION

```
MemoryDivision → "MEMORY DIVISION." Area+

Area → "AREA" identifier (RamArea | BankArea) "SIZE" number ";"

RamArea → "RAM" "(" number ")"
BankArea → "BANK" "(" number "," number ")"
```

Examples:
```
AREA screen RAM($0400) SIZE 1000;
AREA sprites RAM($0800) SIZE 1024;
AREA buffer BANK(1, $A000) SIZE 8192;
```

---

## DATA DIVISION

```
DataDivision → "DATA DIVISION." VariableDeclaration+

VariableDeclaration → "VAR" identifier ":" Type [AreaAnnotation] [VariableInit] ";"

VariableInit → ":=" Expression

AreaAnnotation → "AT" identifier

Type → ArrayType
      | BuiltinType
      | PointerType
      | NamedType

BuiltinType → "uint16" | "uint8" | "int16" | "int8" | "string" | "char" | "byte"

ArrayType → "array" "[" number "]" "of" Type [ArrayInit]
ArrayInit → ":=" "{" ExpressionList "}"

PointerType → "@" identifier

NamedType → identifier
```

Examples:
```
VAR x: uint8;
VAR count: uint8 := 42;
VAR buffer: array[256] of uint8;
VAR flags: array[8] of uint8 := { 1, 0, 1, 0, 1, 0, 1, 0 };
```

---

## ENUM DIVISION

```
EnumDivision → "ENUM DIVISION." EnumDeclaration+

EnumDeclaration → "ENUM" [identifier] "{" EnumMember ("," EnumMember)* "}" ";"

EnumMember → identifier ["=" number | ":=" number]
```

Examples:
```
ENUM Status {
    IDLE = 0,
    RUNNING = 1,
    DONE = 2
};

ENUM Color {
    RED,
    GREEN,
    BLUE
};
```

---

## PROCEDURE DIVISION

```
ProcedureDivision → "PROCEDURE DIVISION." Procedure+

Procedure → "FN" identifier "(" [ParameterList] ")"
            Statement+
            "END"

ParameterList → Parameter ("," Parameter)*
Parameter → identifier ":" Type
```

Example:
```
FN greet(name: uint8)
    SAY "Hello";
    SAY name;
END
```

---

## MAIN DIVISION

```
MainDivision → "MAIN DIVISION." Statement+
```

---

## STATEMENTS

### Control Flow Statements

#### If Statement
```
IfStatement → "IF" Expression "THEN"
                  Statement*
              ("ELSIF" Expression "THEN" Statement*)*
              ["ELSE" Statement*]
              "END"
```

#### While Loop
```
WhileLoop → "WHILE" Expression "DO"
                Statement+
            "END"
```

#### Repeat/Until Loop
```
RepeatLoop → "REPEAT"
                 Statement+
             "UNTIL" Expression ";"
```

#### For Loop
```
ForLoop → "FOR" identifier ":=" Expression "TO" Expression "DO"
              Statement+
          ["END"]
```

#### Case Statement
```
CaseStatement → "CASE" Expression "OF"
                    CaseWhen+
                ["ELSE" Statement+]
                "END"

CaseWhen → "|" CaseSelector ("," CaseSelector)* ":" Statement+
CaseSelector → Range | number | designator
```

### Simple Statements

```
SimpleStatement → Say
                | Echo
                | Assignment
                | ProcedureCall
                | Return

Say → "SAY" Expression ";"
Echo → "ECHO" Expression ";"
Assignment → Designator ":=" Expression ";"
ProcedureCall → identifier "(" [ArgumentList] ")" ";"
Return → "RETURN" Expression ";"

ArgumentList → Expression ("," Expression)*
```

---

## EXPRESSIONS

Expressions follow standard operator precedence: comparison, addition/subtraction, multiplication/division.

```
Expression → Comparison

Comparison → MathSum [CompareOperator MathSum]*
CompareOperator → "==" | "!=" | ">=" | "<=" | ">" | "<"

MathSum → MathProduct [AddOperator MathProduct]*
AddOperator → "+" | "-"

MathProduct → Factor [MulOperator Factor]*
MulOperator → "*" | "/"

Factor → "(" Expression ")"
       | RamAccess
       | BankAccess
       | Number
       | String
       | Designator
       | "~" Factor

RamAccess → "RAM" "[" Expression "]"
BankAccess → "BANK" "(" Expression ")" "[" Expression "]"

Designator → [identifier "."] identifier Selector*
Selector → "[" Expression "]"       // Array/map access
         | "." identifier            // Field access
         | "(" [ArgumentList] ")"    // Function call
```

### Memory Access

RAM and BANK can be accessed directly in expressions:
```
value := RAM[$D020];           // Read from address $D020
RAM[$D020] := 6;               // Write to address $D020
screen[i] := 32;               // Access named memory area
BANK(1)[$A100] := 42;          // Access banked memory
```

---

## LITERALS

```
Number → DecNumber | HexNumber
DecNumber → digit+
HexNumber → "$" hex-digit+

String → '"' [ <not-quote> | '\\' any-char ]* '"'

Identifier → [a-zA-Z_] [a-zA-Z0-9_-]*
```

---

## COMMENTS

```
Comment → "//" [ <not-newline> ]*
```

Comments can appear anywhere whitespace is allowed and extend to the end of the line.

Example:
```
MAIN DIVISION.
    // This is a comment
    x := 42;  // Initialize x
    SAY x;
```

---

## INITIALIZATION EXPRESSIONS

Initialization expressions are used for variables, constants, and macro parameters:

```
NestedInit → Number
           | String
           | RecordInit
           | EnumInit
           | ArrayInit

RecordInit → "{" NestedInitList "}"
EnumInit → "{" NestedInitList "}"
ArrayInit → "{" NestedInitList "}"

NestedInitList → NestedInit ("," NestedInit)*
```

---

## COMPLETE EXAMPLE

```
MODULE IDENTIFICATION DIVISION.
    MODULE-ID. Calculator.
    AUTHOR. Developer.
    DESCRIPTION. A simple calculator program.

CONSTANTS DIVISION.
    MAX_VALUE: uint16 IS 65535;

MEMORY DIVISION.
    AREA display RAM($0400) SIZE 1000;

DATA DIVISION.
    VAR x: uint8 := 10;
    VAR y: uint8 := 20;
    VAR result: uint8;

PROCEDURE DIVISION.
    FN add(a: uint8, b: uint8)
        RETURN a + b;
    END

MAIN DIVISION.
    // Calculate sum
    result := add(x, y);
    SAY result;
    
    // Display area access
    display[0] := result;
    
MODULE END.
```

---

## GRAMMAR NOTES

- Semicolons (`;`) terminate statements and declarations
- Whitespace and comments are automatically skipped
- Left-biased PEG matching means first alternative wins
- Keywords are case-insensitive in most contexts
- Identifiers can contain hyphens (e.g., `my-var`)
