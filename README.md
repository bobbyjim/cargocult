# cargocult
A DSL compiler for the Commander X16, written in Raku

# BNF
```
<program> ::= <main-file> | <package-declarations>+

<main-file> ::= @include <file>+ <top-level-code>

<top-level-code> ::= <statement>+
<statement> ::= <declaration> | <expression> | <function-call> | <print-statement> | <package-call>

<declaration> ::= <type> <variable-name> : <type> = <expression>
<type> ::= uint8 | uint16 | uint32 | int8 | int16 | int32 | char | void
<variable-name> ::= <identifier>
<function-call> ::= <identifier> ( <argument-list>? )
<expression> ::= <identifier> | <literal> | <expression> <operator> <expression> | <function-call> 
<literal> ::= <number> | <string> | <boolean>
<operator> ::= + | - | * | / | == | != | < | <= | > | >=
<identifier> ::= [a-zA-Z_][a-zA-Z0-9_]*
<argument-list> ::= <expression> ( , <expression> )*
<print-statement> ::= print ( <expression> )
<package-call> ::= <package-name>.<function-name> ( <argument-list>? )

<package-declarations> ::= <package-declaration>+
<package-declaration> ::= package <package-name> { <package-body> }
<package-name> ::= <identifier>
<package-body> ::= <declaration>* <function>*
<function> ::= function <function-name> ( <parameter-list>? ) : <type> { <function-body> }
<function-name> ::= <identifier>
<parameter-list> ::= <parameter> ( , <parameter> )*
<parameter> ::= <type> <parameter-name> : <type>
<parameter-name> ::= <identifier>
<function-body> ::= <statement>*
<package-call> ::= <package-name>.<function-name> ( <argument-list>? )

```
# Features
## Strong Typing
Variables and functions have explicit types, which translates well to the 6502's needs for predictable memory and data handling.

``   var score: uint16 = 42;``

## Block Delimiters with Braces
{} for blocks makes parsing straightforward and eliminates ambiguities.
```
   function calculate(x: uint8, y: uint8): uint16 {
      return x + y;
   }
```
## Assignment with =
Matches convention in most languages, intuitive to use.

## Clear Declaration Syntax
Borrowing ECMAScript syntax gives it a modern feel while staying structured.

## Data Types
Uses types that map directly to the 6502's strengths:

* uint8, int8: 8-bit integers.
* uint16, int16: 16-bit integers.
* fixed8_8: Fixed-point numbers for game physics or graphics.
* char: Alias for uint8.

## Memory Management
Introduce explicit memory location constructs for fine control:

``   var spriteX: uint8 @ $0400;  // Bind variable to specific memory address``

## Inline Assembly
Provide a way to insert raw 6502 assembly for low-level control:
```
   asm {
      LDA #$01
      STA $D020
   }
```
## Structs
```
   struct Point {
      x: uint16;
      y: uint16;
   }

   var position: Point = { x: 10, y: 20 };
```

## Arrays

``   var highScores: uint16[10] = [100, 200, 300];``

## Sweet 16 Integration
Incorporate Sweet 16 for handling larger computations seamlessly:
```
   function multiply(x: uint16, y: uint16): uint16 {
       sweet16 {
          LDI x
          MUL y
       }
       return %S16_RESULT;
   }
```
# Goals
Ease of Compilation to 6502 Assembly:
* Use types and constructs that map naturally to 6502 architecture (e.g., integral types like uint8, int8, uint16, int16).
* Optimize for memory and performance given the constraints of the platform.
* Consider using a Sweet 16-like interpreter for 16-bit operations.

Readable and Enjoyable Syntax:
* Avoid cryptic syntax that distracts or frustrates developers.
* Focus on unambiguous grammar to simplify tokenization and parsing.
* Include modern conveniences (e.g., inline assembly, arrays, structs, functions).

Approachable Language Paradigm:
* Draw inspiration from established paradigms like Pascal, C, or Python for familiarity.
* Keep the syntax simple but allow for extensibility if needed.
