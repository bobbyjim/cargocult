# I. Xenober16
This is a retro-aesthetic language for transpiling to something like cc65 or Prog8.

It is inspired by Oberon's syntax combined with COBOL's division-based organization. 

The AST is, for all practical purposes, the Intermediate Representation. I only need the AST Intermediate Representation > Code to be structurally and semantically valid.

Transpiling gives me shortcuts.  I don't need to implement:
* low-level optimization
* register allocation
* linking
* emitting efficient jump tables
* aligning structs in memory (mostly)
* resolving cross-module calls

# II. Language Structure
* Note: The file passed to the xen16 command is the MAIN module.
* Divisions: Modular, COBOL‑inspired clarity.

Program           <- IdentificationDiv ImportDiv? MemoryDiv? DataDiv? CodeDiv

## Lexicals

   Identifier        <- [A-Za-z_] [A-Za-z0-9_]*
   Number            <- [0-9]+
   HexLiteral        <- '$' [0-9A-Fa-f]+
   StringLiteral     <- '"' [^"]* '"'

## Identification Division (mandatory)
This section is parsed first and acts as a "header" and metadata holder for the module.

   IdentificationDiv <- 'IDENTIFICATION DIVISION.' IdentifierSection* 'END IDENTIFICATION DIVISION.'
   IdentifierSection <- IdentifierDef ';'
   IdentifierDef     <- Identifier '=' StringLiteral

- MODULE-ID: (Mandatory): Designates the module name.
- PARAMETERS: (Optional): Template values for instances of this module.
- AUTHOR: (Optional)
- DATE: (Optional)
- DESCRIPTION: (Optional)
- LICENSE: (Optional)

## Import Division (Optional)
USE statements (one per line): Declares module dependencies.

		USE MyModule.
		USE stdio.
		USE string.

## Memory Division (Optional)
* AREAs: First-class in Placement via @Identifier.

   MemoryDiv         <- 'MEMORY DIVISION.' MemoryDecl+ 'END MEMORY DIVISION.'
   MemoryDecl        <- 'AREA' Identifier StorageSpec SizeSpec ';'
   StorageSpec       <- 'BANK' '(' BankNumber ',' Address ')'
                      / 'RAM'  '(' Address ')'
   SizeSpec          <- 'SIZE' '(' Number ')'
   BankNumber        <- Number
   Address           <- HexLiteral

## Data Division (Optional)
* Slices: Can reference an existing array directly with SLICE[myArray, 10..20].
* Enums: Simple, no explicit values — keeps it clean.

WORKING-STORAGE SECTION. (Mandatory): Contains variable and type declarations.

   DataDiv           <- 'DATA DIVISION.' DataSection+ 'END DATA DIVISION.'
   DataSection       <- WorkingStorageSection
   WorkingStorageSection
                      <- 'WORKING-STORAGE SECTION.' VarDecl+ 'END WORKING-STORAGE SECTION.'
   VarDecl           <- Identifier ':' TypeSpec Placement? ';'
   Placement         <- '@' Identifier
   
   TypeSpec          <- BaseType
                      / ArrayType
                      / SliceType
                      / RecordType
                      / EnumType
   BaseType          <- 'INT8' / 'INT16' / 'UINT8' / 'UINT16' / 'CHAR'
   
   ArrayType         <- 'ARRAY' '[' Number ']' 'OF' TypeSpec
   SliceType         <- 'SLICE' '[' Identifier ',' Range ']' 
   RecordType        <- 'RECORD' RecordField+ 'END RECORD'
   RecordField       <- Identifier ':' TypeSpec ';'
   EnumType          <- 'ENUM' EnumMemberList
   EnumMemberList    <- Identifier (',' Identifier)*
   
   Range             <- Number '..' Number
                      / Number '..'

## Code Division (Optional)
* Statements: Structured and Oberon-like, but adapted to Xenober16’s flavor.

   CodeDiv           <- 'CODE DIVISION.' ProcDecl+ 'END CODE DIVISION.'
   ProcDecl          <- 'PROCEDURE' Identifier '(' ParamList? ')' ';' 
                        Block
                        'END' Identifier ';'
   ParamList         <- Param (',' Param)*
   Param             <- Identifier ':' TypeSpec   

   Block             <- 'BEGIN' Statement* 'END'
   Statement         <- Assignment
                      / IfStmt
                      / CaseStmt
                      / LoopStmt
                      / ProcCall
                      / SystemCall
                      / ';'   # empty stmt allowed   

   Assignment        <- Identifier Placement? ':=' Expression ';'
   ProcCall          <- Identifier '(' ArgList? ')' ';'
   ArgList           <- Expression (',' Expression)*
   SystemCall        <- '%SYS.' Identifier '(' ArgList? ')' ';'   

   IfStmt            <- 'IF' Expression 'THEN' Statement+ ( 'ELSE' Statement+ )? 'END IF;'
   CaseStmt          <- 'CASE' Expression 'OF' CaseBranch+ 'END CASE;'
   CaseBranch        <- Literal ':' Statement+
   LoopStmt          <- ForLoop / WhileLoop
   ForLoop           <- 'FOR' Identifier ':=' Expression 'TO' Expression Block 'END FOR;'
   WhileLoop         <- 'WHILE' Expression Block 'END WHILE;'   

   Expression        <- OrExpr
   OrExpr            <- AndExpr ( 'OR' AndExpr )*
   AndExpr           <- RelExpr ( 'AND' RelExpr )*
   RelExpr           <- AddExpr ( RelOp AddExpr )*
   RelOp             <- '=' / '<>' / '<' / '<=' / '>' / '>='
   AddExpr           <- MulExpr ( ('+' / '-') MulExpr )*
   MulExpr           <- Primary ( ('*' / '/' / 'MOD') Primary )*
   Primary           <- Number
                      / StringLiteral
                      / Identifier
                      / '(' Expression ')'

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
* MACRO DIVISION works well with the static model; preprocess these before parsing expressions.
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
                            [ MacroDivision ]
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
        BankLine        ::= "BANK-ID:" BankNumber
        
        TextLine        ::= (any non-newline characters)
        BankNumber      ::= [1..9]\d?

        ParamList       ::= "(" ParamDecl { "," ParamDecl } ")"
        ParamDecl       ::= Identifier ":" TypeName [ ":=" Expression ]
        
        DataDivision    ::= "DATA DIVISION."
                            [ WorkingStorageSection ]
                            [ EnumSection ]

        MacroDivision    ::= "MACRO DIVISION."
                            { MacroDecl }
                                    
        WorkingStorageSection  ::= "WORKING-STORAGE SECTION."
                                   { VarDecl }
        
        EnumSection     ::= "ENUM SECTION."
                            { EnumDecl }
        
        MacroDecl       ::= Identifier ":=" Expression ";"
                          | Identifier ParamList ":=" Expression ";"

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
                              { ProcDecl }
                
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
        TypeName        ::= "INT16" | "BYTE" | "UINT16" | "UBYTE" | "CHAR" | "INT32" | "UINT32" | Identifier
        Identifier      ::= (starts with letter/underscore, then alphanumerics)

