# I. Xenober16
"A mundane transpiler for annoying times"

In short, this is for transpiling to something like cc65 or Prog8.

Retro aesthetics, inspired by Oberon's readability and structure combined with COBOL's division-based organization. 

The AST is, for all practical purposes, the Intermediate Representation. I only need the AST Intermediate Representation > Code to be structurally and semantically valid.

Transpiling gives me shortcuts.  I don't need to implement:
* low-level optimization
* register allocation
* linking
* emitting efficient jump tables
* aligning structs in memory (mostly)
* resolving cross-module calls

# II. Language Structure

The language follows a rigid division-based structure.

* Note: The file passed to the xen16 command is the MAIN module.

## MODULE IDENTIFICATION DIVISION: (Mandatory)
This section is parsed first and acts as a "header" and metadata holder for the module.

    MODULE-ID: (Mandatory): Designates the module name.
    PARAMETERS: (Optional): Template values for instances of this module.
    AUTHOR: (Optional)
    DATE: (Optional)
    DESCRIPTION: (Optional)
    LICENSE: (Optional)

## IMPORT DIVISION: (Optional)
USE statements (one per line): Declares module dependencies.

		USE MyModule.
		USE stdio.
		USE string.

## DATA DIVISION: (Optional)
WORKING-STORAGE SECTION. (Mandatory): Contains variable and type declarations.
 
    myVar : INT16 := 12_000;

* Oberon-style syntax for declarations (e.g., variableName : DataType := initialValue;).
* Type definitions (records, arrays) are also located in this section.

## CODE DIVISION: (Optional)

    WHILE myVar > 0 DO
	   SAY myVar;
	   myVar := myVar - 10;
	END

* Contains executable code.
* Oberon-style syntax for procedures and the main program body.
* BEGIN and END keywords mark the start and end of procedures.
* The END tag does not include the MODULE-ID.
* No BEGIN keyword is used to demarcate the start of the main program body.

# III. Data Types
* INT8, INT16, INT24, UINT8, UINT16, UINT24.
* CHAR.
* Fixed-Point: maybe.
* Arrays: Statically sized arrays.
* Records (Structures): Used for grouping data.
* Pointers: Supported for memory manipulation.

# IV. Memory Management
Annotations: Used to specify memory locations for variables.

* @BANK(bankNumber, address): Places the variable in banked RAM.
* @RAM(address): Places the variable in directly addressable RAM ("golden RAM").
* @ZEROPAGE(offset): Places the variable in zero page at the given offset.

    myVar : ARRAY[20] OF INT16 @BANK(1, $A000);
    myRec : MyCoolRecord @BANK(2, $A000);

Automatic Bank Switching: The compiler automatically inserts SetBank() calls when accessing banked memory locations.

No Direct RAM Assignment: Direct assignment to RAM using a $ prefix is not supported.

# V. Register Access

    %SYS Object: A built-in object for accessing system-level resources.
    %SYS.R0 - %SYS.R15: Access to the 16 pseudo-registers.
    %SYS.R0L, %SYS.R0H - %SYS.R15L, %SYS.R15H: Access to the low and high bytes of the pseudo-registers.
    %SYS.A, %SYS.X, %SYS.Y, %SYS.P: Read-only access to the CPU registers.

* Writing to CPU Registers: Requires the use of inline assembly.

# VI. System Calls and Information:

%SYS Object (Extended): May include aliases for commonly used KERNAL routines (e.g., %SYS.chrout()). Provides access to system information (e.g., %SYS.clock).

# VII. Memory Access Functions:

* %SYS.poke(address, value): Writes a byte to memory. Supports a list of values for sequential writes.
* %SYS.peek(address): Reads a byte from memory.

# VIII. Bitfields:

* Defined using the @BITFIELD(width) annotation within records.
* Can define fields from 1 to 15 bits long.
* Example: value : @BITFIELD(12);
* Bitfields are implicitly unsigned integral types.

The compiler infers the underlying type based on the width:

    @BITFIELD(1) - @BITFIELD(8): Uses one byte
    @BITFIELD(9) - @BITFIELD(15): Uses two bytes

Compiler generates code to handle masking and shifting.

# IX. Control Flow:

* IF-THEN-ELSE, WHILE, FOR, LOOP.
    * FOR loops have predictable bounds.
* Trailing IF conditions some statements.
	* LAST [IF <expr>];
	* SAY <expr> [IF <expr>];
* CASE statements (C-style comparisons, and chained-if semantics in the interpreter).
* ASSERT expression;
* ASSERT expression ELSE "Optional message";

# X. Modules and Imports:

* Modules are defined using the division structure (MODULE-ID serves as the module name).
* Modules are imported using the USE keyword in the IMPORT DIVISION.
* Exported members are denoted with a trailing asterisk (*) after the name in declarations, for example, Main* : PROC();
* To call a method in another module, specify the namespace e.g. OtherModule.AMethod()
* The compiler enforces namespace qualifications.

# XI. MAIN Module:

* One module per program must be designated the MAIN module with the MAIN. annotation.
* That module contains the program's entry point in a procedure Main()
* The MAIN module is also where global variables are declared.

# XII. Inline Assembly:

Allows embedding 6502 assembly code directly within the language. For example, something like this:

    ASM
        LDA #65
        JSR $FFD2
    END

# XIII. Exclusions:

* No sets.
* No real numbers (floating-point).
* No dynamic memory allocation (NEW, MALLOC, FREE, DISPOSE).
* No standalone Boolean Type.

# XIV. Standard Library:

* VERA
* SPRITE
* KERNAL
* MEM
* MATH

# XV. Grammar Notes:

* Constant expressions are always folded at compile time, including bitwise ops, math, and field offsets.
* This is a high-level sketch intended for reference, not a full parser grammar.      
* Macro support via #DEFINE works well with the static model; preprocess these before parsing expressions.
* ENUM SECTION is modeled explicitly like CONST SECTION.
* Array slices use an extended lvalue grammar: buffer[64..128] or buffer[3].
* Pragmas attach to var-decl or proc-decl. Store these in the AST as a list of symbols and optional values.
* Procedure overloading is resolved by mangling names based on the parameter types — ASTBuilder will handle this during symbol table construction or codegen.
* Inline procs are simply procedure literals, no captures — just wrap in a small ProcLiteralNode with an anonymous name.

        Program         ::= "MODULE IDENTIFICATION DIVISION."
                            ModuleID
                            [ ParametersLine ]
                            [ AuthorLine ]
                            [ DateLine ]
                            [ DescriptionLine ]
                            [ LicenseLine ]
                            [ DataDivision ]
                            [ TypeDivision ]
                            [ ProcedureDivision ]
                            "END MODULE."
        
        ModuleID        ::= "MODULE-ID:" Identifier
        ParametersLine  ::= "PARAMETERS:" ParamDecl { "," ParamDecl } ";"
        AuthorLine      ::= "AUTHOR:" TextLine
        DateLine        ::= "DATE:" TextLine
        DescriptionLine ::= "DESCRIPTION:" TextLine
        LicenseLine     ::= "LICENSE:" TextLine
        
        TextLine        ::= (any non-newline characters)
        
        ParamDecl       ::= Identifier ":" TypeName [ ":=" Expression ]
        
        DataDivision    ::= "DATA DIVISION."
                            [ ConstantStorageSection ]
                            [ WorkingStorageSection ]
                            [ EnumSection ]
        
        ConstantStorageSection ::= "CONSTANT-STORAGE SECTION."
                                   { ConstDecl }
        
        WorkingStorageSection  ::= "WORKING-STORAGE SECTION."
                                   { VarDecl }
        
        EnumSection     ::= "ENUM SECTION."
                            { EnumDecl }
        
        ConstDecl       ::= Identifier ":=" Expression ";"
        VarDecl         ::= Identifier ":" TypeName [ ":=" Expression ] [ PragmaList ] ";"
        
        EnumDecl        ::= "ENUM" Identifier "{" EnumEntry { "," EnumEntry } "}" ";"
        EnumEntry       ::= Identifier [ "=" Expression ]
        
        TypeDivision    ::= "TYPE DIVISION."
                            { TypeDecl }
        
        TypeDecl        ::= "TYPE" Identifier "=" TypeExpr ";"
        
        TypeExpr        ::= TypeName
                          | "ARRAY" Expression "OF" TypeExpr
                          | "SLICE" "OF" TypeExpr
                          | "RECORD" { FieldDecl } "END"
                          | "PROC" "(" [ ParamDecl { "," ParamDecl } ] ")" [ ":" TypeName ]
        
        FieldDecl       ::= Identifier { "," Identifier } ":" TypeName ";"
        
        ProcedureDivision ::= "CODE DIVISION."
                              { MacroDecl }
                              { ProcDecl }
        
        MacroDecl       ::= "#DEFINE" Identifier "=" Expression ";"
        
        ProcDecl        ::= [ PragmaList ]
                            "PROC" Identifier "(" [ ParamDecl { "," ParamDecl } ] ")" [ ":" TypeName ]
                            [ "=" Identifier ]       (* Optional manual mangled name *)
                            ProcBody
        
        ProcBody        ::= "BEGIN" { Statement } "END" Identifier ";"
        
        PragmaList      ::= "[" Pragma { "," Pragma } "]"
        Pragma          ::= Identifier [ "(" Expression ")" ]
        
        Statement       ::= AssignStmt
                          | CallStmt
                          | IfStmt
                          | WhileStmt
                          | ReturnStmt
                          | InlineProc
                          | "ASSERT" Expression [ "ELSE" StringLiteral ] ";"
                          | SayStmt
        
        AssignStmt      ::= LValue ":=" Expression ";"
        CallStmt        ::= Identifier "(" [ Expression { "," Expression } ] ")" ";"
        ReturnStmt      ::= "RETURN" [ Expression ] ";"
        IfStmt          ::= "IF" Expression "THEN" { Statement }
                            { "ELSIF" Expression "THEN" { Statement } }
                            [ "ELSE" { Statement } ]
                            "END" ";"
        WhileStmt       ::= "WHILE" Expression "DO" { Statement } "END" ";"
        
        InlineProc      ::= "PROC" "(" [ ParamDecl { "," ParamDecl } ] ")" [ ":" TypeName ]
                            "BEGIN" { Statement } "END"
        
        SayStmt         ::= "SAY" Expression ";"
        
        LValue          ::= Identifier [ "[" Expression [ ".." Expression ] "]" ]
        
        Expression      ::= (integer literal | identifier | ... )   (* Placeholder *)
        TypeName        ::= "INT16" | "BYTE" | "WORD" | "CHAR" | Identifier
        Identifier      ::= (starts with letter/underscore, then alphanumerics)
                