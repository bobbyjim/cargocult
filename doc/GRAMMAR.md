# XENOBER16 GRAMMAR - EBNF SUMMARY

## Overview
This is a COBOL-inspired language targeting the Commodore 16 8-bit computer.
The grammar uses PEG (Parsing Expression Grammar) with left-biased choice for deterministic parsing.

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
Description → ("DESCRIPTION." | "WHAT:" | "DESC:") RestOfLine
Purpose → ("PURPOSE." | "WHY:") RestOfLine
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

```
MacroDivision → "MACRO DIVISION." MacroDeclaration+

MacroDeclaration → identifier ":" MacroType "IS" Expression ";"

MacroType → "int8" | "int16" | "byte" | "uint8" | "uint16" | "char" | "string"
```

---

## MEMORY DIVISION

```
MemoryDivision → "MEMORY DIVISION." Area+

Area → "AREA" identifier (RamArea | BankArea) "SIZE" number ";"

RamArea → "RAM" "(" number ")"
BankArea → "BANK" "(" number "," number ")"
```

---

## DATA DIVISION

```
DataDivision → "DATA DIVISION." VariableDeclaration+

VariableDeclaration → "VAR" identifier ":" Type AreaAnnotation? ";"

Type → ArrayType | BuiltinType | PointerType | InlineType | NamedType

ArrayType → ("array" | "ARRAY") "[" number "]" ("of" | "OF") Type
BuiltinType → "uint16" | "uint8" | "int16" | "int8" | "string" | "char" | "byte"
PointerType → "@" identifier
InlineType → RecordType | EnumType
NamedType → identifier

RecordType → "RECORD" RecordField* "END"
RecordField → identifier ":" Type BitfieldAnnotation? ";"
BitfieldAnnotation → "@BITFIELD" "(" number ")"

AreaAnnotation → "AT" identifier
```

---

## ENUM DIVISION

```
EnumDivision → "ENUM DIVISION." EnumDeclaration+

EnumDeclaration → "ENUM" identifier EnumMember+ "END ENUM" ";"

EnumType → "ENUM" identifier EnumMember+ "END ENUM"
EnumMember → identifier ("=" number | ":=" number)? ("," EnumMember)*
```

---

## PROCEDURE DIVISION

```
ProcedureDivision → "PROCEDURE DIVISION." Procedure+

Procedure → "PROC" identifier "(" ParameterList? ")"
            Statement+
            "END"

ParameterList → Parameter ("," Parameter)*
Parameter → identifier ":" Type
```

---

## MAIN DIVISION

```
MainDivision → "MAIN DIVISION." Statement+
```

---

## STATEMENTS

```
Statement → KeywordStatement | SimpleStatement

KeywordStatement → IfStatement | WhileLoop | ForLoop | RepeatLoop | CaseStatement

SimpleStatement → Say | Echo | Assignment | ProcedureCall

Assignment → Designator ":=" Expression ";"
Say → "SAY" Expression ";"
Echo → "ECHO" Expression ";"
ProcedureCall → identifier "(" ArgumentList? ")" ";"
ArgumentList → Expression ("," Expression)*
```

---

## CONTROL FLOW

```
IfStatement → "IF" Expression ("THEN" | "DO")
              Statement*
              ("ELSIF" Expression ("THEN" | "DO") Statement*)*
              ("ELSE" Statement*)?
              "END"

WhileLoop → "WHILE" Expression "DO" Statement+
            ("ELSIF" Expression "DO" Statement+)*
            ";"? "END"

RepeatLoop → "REPEAT" Statement+ "UNTIL" Expression ";"?

ForLoop → "FOR" identifier ":=" Expression "TO" Expression "DO"
          Statement+
          ";"? "END"

CaseStatement → "CASE" Comparison "OF"
                CaseWhen+
                ("ELSE" Statement+)?
                "END"

CaseWhen → "|" CaseSelector ("," CaseSelector)* ":" Statement+
CaseSelector → Range | number | Designator

Range → number ".." number
```

---

## EXPRESSIONS

```
Expression → Comparison

Comparison → MathSum (CompareOp MathSum)*
CompareOp → "==" | "!=" | ">=" | "<=" | ">" | "<"

MathSum → MathProduct (AddOp MathProduct)*
AddOp → "+" | "-"

MathProduct → Factor (MulOp Factor)*
MulOp → "*" | "/"

Factor → string
        | "(" Expression ")"
        | RamAccess
        | BankAccess
        | number
        | Designator

RamAccess → "RAM" "[" Expression "]"
BankAccess → "BANK" "(" Expression ")" "[" Expression "]"
```

---

## DESIGNATORS

```
Designator → Qualident Selector*
Qualident → (identifier ".")? identifier
Selector → "[" Expression "]"
         | "." identifier
```

---

## TERMINALS

```
identifier → [a-zA-Z_] ([a-zA-Z0-9_-])*
number → DecNumber | HexNumber
DecNumber → [0-9]+
HexNumber → "$" [0-9a-fA-F]+
string → '"' (not-quote | '\\' .)* '"'
RestOfLine → [^"\n"]*

KEYWORDS (case-insensitive in some contexts):
  MODULE, IDENTIFICATION, DIVISION, ID, PARAMETERS, PARAMS, AUTHOR, WHO, BY
  DESCRIPTION, WHAT, DESC, PURPOSE, WHY, IMPORT, USE, MEMORY, AREA, SIZE
  RAM, BANK, MACRO, CONSTANTS, DATA, ENUM, END, RECORD, AT, PROC, PROCEDURE
  MAIN, SAY, ECHO, IF, THEN, ELSIF, ELSE, WHILE, REPEAT, UNTIL, DO, FOR, TO
  CASE, OF, RETURN

OPERATORS:
  ":=" (assignment)
  "=" (equality)
  "<>" (not equal)
  "==" (equality alt)
  "!=" (not equal alt)
  "<", "<=", ">", ">=" (comparison)
  "+", "-" (addition/subtraction)
  "*", "/" (multiplication/division)
  ".." (range)
  "@" (pointer prefix)
  "|" (case selector)
  "[", "]" (array/memory access)
  "(", ")" (grouping)
  "," (separator)
  "." (field access)
  ";" (statement terminator)
  ":" (declaration separator)
  "~" (bitwise NOT - in factor)
  "&" (string concatenation - in expressions)
```

---

## PARSING CHARACTERISTICS

- **Grammar Type**: PEG (Parsing Expression Grammar)
- **Parse Strategy**: Predictive, left-biased choice (no backtracking at runtime with proper LL(1) ordering)
- **Precedence**: Explicit through operator rule hierarchy (Expression → Comparison → MathSum → MathProduct → Factor)
- **Case Sensitivity**: Generally yes, but some keywords support alternatives (e.g., "AUTHOR." vs "WHO:")
- **Required Keywords**: All division headers, "VAR" for variable declarations
- **Optional Elements**: Parameters, alternative keywords, comments

---

## KEY DESIGN DECISIONS

1. **VAR Keyword**: Required prefix for all variable declarations (enhances readability)
2. **Type Hierarchy**: Decomposed into ArrayType, BuiltinType, PointerType, InlineType, NamedType for LL(1) dispatch
3. **Factor Ordering**: Prioritizes unambiguous discriminators (string/parentheses before numbers/identifiers)
4. **Operator Support**: Includes DIV, MOD for integer division; & for string concatenation
5. **Memory Access**: Direct RAM/BANK access without named areas
6. **Comment Syntax**: Supports both "//" and "|*" style comments (in tokens)
7. **Case Flexibility**: Some keywords allow alternatives (WHO: vs AUTHOR., etc.)
