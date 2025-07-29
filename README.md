# Xenober16
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

# Language Structure
* Note: The file passed to the xen16 command is the MAIN module.
* Divisions: Modular, COBOL‑inspired clarity.

Program           <- ModuleHeader MetadataDiv? ImportDiv? MacroDiv? MemoryDiv? DataDiv? CodeDiv

## Lexicals

     Identifier        <- [A-Za-z_] [A-Za-z0-9_]*
     Number            <- [0-9]+
     HexLiteral        <- '$' [0-9A-Fa-f]+
     StringLiteral     <- '"' [^"]* '"'

     Range             <- SimpleRange / RangeToEnd
     SimpleRange       <- ConstExpr '..' ConstExpr
     RangeToEnd        <- ConstExpr '..'

## Pragmas
* Used with Procs and Vars

     Pragma  <- '@' Identifier ( '(' (Identifier '=' ConstExpr)? (',' Identifier '=' ConstExpr)* ')' )?

## Module Header (mandatory)
     ModuleHeader      <- 'MODULE' Identifier ParamList? ';'
     ParamList         <- '(' ParamDecl (',' ParamDecl)* ')'
     ParamDecl         <- Identifier ':' ParamType (':=' ConstExpr)?   # optional default
     ParamType         <- 'INT8' / 'INT16' / 'UINT8' / 'UINT16' / 'CHAR' / 'BOOL'
     ConstExpr         <- Number / HexLiteral / StringLiteral

## Metadata Division (optional)
This section is a metadata holder.

    MetadataDiv <- 'METADATA DIVISION.' 
                         DescriptionDecl
                         AuthorDecl?
                         DateDecl?
                         LicenseDecl?
                         'END METADATA DIVISION.'
        
    AuthorDecl       <- 'AUTHOR:' StringLiteral ';'
    DateDecl         <- 'DATE:' StringLiteral ';'
    DescriptionDecl  <- 'DESCRIPTION:' StringLiteral ';'
    LicenseDecl      <- 'LICENSE:' StringLiteral ';'

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

     ImportDiv <- 'IMPORT DIVISION.' UseThing* 'END IMPORT DIVISION.'
     UseThing  <- 'USE ' Identifier ';'

* To call a method in another module, specify the namespace e.g. OtherModule.AMethod()
* The compiler enforces namespace qualifications.

Standard library ideas:
* VERA
* SPRITE
* KERNAL
* MEM
* MATH

## Macro Division (optional)
Formal grammar for MACRO DIVISION is deferred. Implementations may ignore the section.

Plan: a simple Constant-style text substitution at parse time. Works for constants, maybe even short inline expressions. Low risk and easy.

     MACRO DIVISION.
         MAX_PLAYERS := 4;
         SCREEN_BASE := $0400;
         BUFFER_SIZE := 32 * 4;
         MAX_INDEX   := BUFFER_SIZE - 1;
         DIGITS      := '0'..'9'; // stores a Range node in the AST.
     END MACRO DIVISION.

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
* A Data Division may contain at most one Working‑Storage Section, one Enum Section, and one Assertion Section.
* Slices: Can reference an existing array directly with SLICE[myArray, 10..20].
* Enums: Simple, no explicit values, UINT8-backed starting at zero.
* Assertions: Compile‑time invariants. Like guardrails in the source, enforced before code generation. If the assertion fails, compilation halts with an error. No runtime code is generated for assertions.

     ASSERT SECTION.
         ASSERT SIZEOF(MyRecord) <= 32;
         ASSERT MAX_PLAYERS <= 8;
     END ASSERT SECTION.

WORKING-STORAGE SECTION. (Mandatory): Contains variable and type declarations.

     DataDiv           <- 'DATA DIVISION.' DataSection* 'END DATA DIVISION.'
     DataSection       <- WorkingStorageSection? EnumSection? AssertionSection?
     WorkingStorageSection
                       <- 'WORKING-STORAGE SECTION.' VarDecl+ 'END WORKING-STORAGE SECTION.'
     VarDecl           <- Pragma* Identifier ':' TypeSpec AreaPlacement? ';'
     AreaPlacement     <- '@' Identifier
     
     TypeSpec          <- BaseType
                        / ArrayType
                        / SliceType
                        / RecordType

     BaseType          <- 'INT8' / 'INT16' / 'UINT8' / 'UINT16' / 'CHAR'
     
     ArrayType         <- 'ARRAY' '[' ConstExpr ']' 'OF' TypeSpec
     SliceType         <- 'SLICE' '[' Identifier ',' Range ']' 
     RecordType        <- 'RECORD' RecordField+ 'END RECORD'
     RecordField       <- Identifier ':' TypeSpec ';'
      

     EnumSection        <- 'ENUM SECTION.' EnumDecl+ 'END ENUM SECTION.'
     EnumDecl           <- Identifier ':' EnumMemberList ';'
     EnumMemberList     <- Identifier (',' Identifier)*

     AssertionSection   <- 'ASSERT SECTION.' AssertDecl+ 'END ASSERT SECTION.'
     AssertDecl         <- 'ASSERT' Expression ';'

## Code Division (Optional)
* Statements: Structured and Oberon-like, but adapted to Xenober16’s flavor.

     CASE key OF
         'A'..'Z': SAY "letter";
         DIGITS: SAY "digit";    // using a macro of a Range here
     ELSE
         SAY "other";
     END CASE;

     CodeDiv           <- 'CODE DIVISION.' ProcDecl+ 'END CODE DIVISION.'
     ProcDecl          <- Pragma* 'PROC' Identifier '(' ParamList? ')' ';' 
                          Block
                          'END' Identifier ';'
     ParamList         <- Param (',' Param)*
     Param             <- Identifier ':' TypeSpec   
  
     Block             <- Statement*
     Statement         <- Assignment
                        / IfStmt
                        / CaseStmt
                        / LoopStmt
                        / ProcCall
                        / SystemCall
                        / SimpleStmt TrailingIf?
                        / ';'   # empty stmt allowed   

     TrailingIf        <- 'IF' Expression ';'
     SimpleStmt        <- 'LAST'
                        / 'SAY' Expression
     Assignment        <- Identifier ':=' Expression ';'
     ProcCall          <- Identifier '(' ArgList? ')' ';'
     ArgList           <- Expression (',' Expression)*
     SystemCall        <- '%SYS.' Identifier '(' ArgList? ')' ';'   
  
     IfStmt            <- 'IF' ExprStmt ( 'ELSIF' ExprStmt )* ( 'ELSE' Statement+ )? 'END IF;'
     ExprStmt          <- Expression 'THEN' Statement+
     CaseStmt          <- 'CASE' Expression 'OF' CaseBranch+ ( 'ELSE' Statement+ )? 'END CASE;'
     CaseBranch        <- (Literal / SimpleRange) ':' Statement+
     LoopStmt          <- ForLoop / WhileLoop
     ForLoop           <- 'FOR' Identifier ':=' Expression 'TO' Expression Block 'END FOR;'
     WhileLoop         <- 'WHILE' Expression Block 'END WHILE;'
  
     Expression        <- OrExpr ( 'IN' SimpleRange )?
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

# KERNAL and Memory Access

* %SYS Object: A built-in object for accessing system-level resources.
* %SYS.R0 - %SYS.R15: Access to the 16 pseudo-registers.
* %SYS.R0L, %SYS.R0H - %SYS.R15L, %SYS.R15H: Access to the low and high bytes of the pseudo-registers.
* %SYS.poke(address, value): Writes a byte to memory. Supports a list of values for sequential writes.
* %SYS.peek(address): Reads a byte from memory.
* %SYS.A, %SYS.X, %SYS.Y, %SYS.P: Read-only access to the CPU registers.

* Writing to CPU Registers: Requires the use of inline assembly.

* %SYS Object (Extended): May include access to the KERNAL (e.g., %SYS.chrout()) and system (e.g., %SYS.clock).

# Bitfields

* Defined using the @BITFIELD(width) annotation within records.
* Can define fields from 1 to 15 bits long.
* Example: value : @BITFIELD(12);
* Bitfields are implicitly unsigned integral types.

The compiler infers the underlying type based on the width:

     @BITFIELD(1) - @BITFIELD(8): Uses one byte
     @BITFIELD(9) - @BITFIELD(15): Uses two bytes

Compiler generates code to handle masking and shifting.

# Trailing IF

* Trailing IF conditions some statements.
* LAST [IF <expr>];
* SAY <expr> [IF <expr>];

# Grammar Notes

* Constant expressions are always folded at compile time, including bitwise ops, math, and field offsets.
* MACRO DIVISION works well with the static model; preprocess these before parsing expressions.
* Pragmas attach to var-decl or proc-decl. Store these in the AST as a list of symbols and optional values.
* Procedure overloading is resolved by mangling names based on the parameter types — ASTBuilder will handle this during symbol table construction or codegen.
* Inline procs are simply procedure literals, no captures — just wrap in a small ProcLiteralNode with an anonymous name.
