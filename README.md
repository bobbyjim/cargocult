# Xenober16
This is a retro-aesthetic language for transpiling to something like cc65 or Prog8.

It is inspired by Oberon-07's syntax combined with COBOL's division-based organization. 

The AST is, for all practical purposes, the Intermediate Representation. I only need the AST Intermediate Representation > Code to be structurally and semantically valid.

Transpiling gives me shortcuts.  I don't need to implement:
* low-level optimization
* register allocation
* linking
* emitting efficient jump tables
* aligning structs in memory (mostly)
* resolving cross-module calls

# Language Structure
Note: The file passed to the xen16 command is the MAIN module.

Divisions: Modular, COBOL‑inspired clarity.

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
     ParamType         <- 'INT8' / 'INT16' / 'UINT8' / 'UINT16' / 'CHAR'
     ConstExpr         <- Number / HexLiteral / StringLiteral / QualIdent

Note: ConstExpr can reference Macro Division identifiers.

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

		USE MyModule AS foo;
		USE stdio.
		USE string.

     ImportDiv <- 'IMPORT DIVISION.' UseThing* 'END IMPORT DIVISION.'
     UseThing  <- 'USE' Identifier (ALIAS)? ';'
     Alias     <- 'AS' Identifier

* To call a method in another module, specify the namespace e.g. OtherModule.AMethod()
* The compiler enforces namespace qualifications.

Standard library ideas:
* VERA
* SPRITE
* MEM
* MATH

## Macro Division (optional)
Formal grammar for MACRO DIVISION is deferred. Implementations may ignore the section.

MACRO DIVISION works well with the static model; preprocess these before parsing expressions.  Or, text subsitution at parse time.

     MACRO DIVISION.
         MAX_PLAYERS := 4;
         SCREEN_BASE := $0400;
         BUFFER_SIZE := 32 * 4;
         MAX_INDEX   := BUFFER_SIZE - 1;
         DIGITS      := '0'..'9'; // stores a Range node in the AST.
     END MACRO DIVISION.

## Memory Division (Optional)
AREAs: First-class in Placement via @Identifier.

     MemoryDiv         <- 'MEMORY DIVISION.' MemoryDecl+ 'END MEMORY DIVISION.'
     MemoryDecl        <- 'AREA' Identifier StorageSpec SizeSpec ';'
     StorageSpec       <- 'BANK' '(' BankNumber ',' Address ')'
                        / 'RAM'  '(' Address ')'
     SizeSpec          <- 'SIZE' '(' Number ')'
     BankNumber        <- Number
     Address           <- HexLiteral

### AREA Example
AREA is used to map out the memory of the system, in one place. 

     MEMORY DIVISION.
         AREA MyArea BANK(1, $C000) SIZE(256);
         AREA SpriteArea RAM($0400) SIZE(128);
     END MEMORY DIVISION.

Allow Inline Area Placement: Allow variables to be assigned to areas directly within their declarations using the @ syntax:

     DATA DIVISION.
         WORKING-STORAGE SECTION.
             VAR x : INT16 @MyArea;        // x is located in MyArea
             VAR sprite : Sprite @SpriteArea;  // sprite is located in SpriteArea
         END WORKING-STORAGE SECTION.
     END DATA DIVISION.


## Data Division (Optional)
A Data Division may contain at most one Working‑Storage Section, one Enum Section, and one Assertion Section.

Enums: Simple, no explicit values, UINT8-backed starting at zero.

Assertions: Compile‑time invariants. Like guardrails in the source, enforced before code generation. If the assertion fails, compilation halts with an error. No runtime code is generated for assertions.

### Arrays
Arrays are declared with a fixed size at compile time (e.g., ARRAY[100] OF INT16).
Arrays are allocated in static memory (within an AREA or a default memory region).
Arrays are passed by reference to procedures (meaning that the procedure receives a pointer to the original array data).
Use a slice-like syntax to do “pointer arithmetic”-like things.
No need for a specific SLICE if you can manipulate array data with a range index.
 
     VAR myArray : ARRAY[100] OF INT16;
     VAR myValue : INT16;
     myValue := myArray[10];       // Access a single element
     myArray[20..29] := 0;    //Set ten elements of the array to zero

 
Slices: Views into Arrays

Slice indexing uses Range syntax within brackets.

Purpose: Slices provide a way to access a contiguous portion of an array without creating a separate copy of the data.
Implementation:
A slice is essentially a descriptor that contains:
* A pointer to the base address of the array.
* A starting index within the array.
* An ending index (or length) of the slice.

When you access an element of a slice (e.g., mySlice[5]), the compiler generates code to calculate the actual memory address by adding the starting index of the slice to the base address of the array and then adding the element offset (5 in this case).

     ASSERT SECTION.
         ASSERT SIZEOF(MyRecord) <= 32;
         ASSERT MAX_PLAYERS <= 8;
     END ASSERT SECTION.

### Grammar

WORKING-STORAGE SECTION. Contains variable and type declarations.

     DataDiv           <- 'DATA DIVISION.' DataSection* 'END DATA DIVISION.'
     DataSection       <- WorkingStorageSection? EnumSection? AssertionSection?
     WorkingStorageSection
                       <- 'WORKING-STORAGE SECTION.' VarDecl+ 'END WORKING-STORAGE SECTION.'
     VarDecl           <- Pragma* Identifier ':' TypeSpec AreaPlacement? ';'
     AreaPlacement     <- '@' Identifier
     
     TypeSpec          <- BaseType
                        / ArrayType
                        / RecordType

     BaseType          <- 'INT8' / 'INT16' / 'UINT8' / 'UINT16' / 'CHAR'
     
     ArrayType         <- 'ARRAY' '[' ConstExpr ']' 'OF' TypeSpec
     RecordType        <- 'RECORD' RecordField+ 'END RECORD'
     RecordField       <- Identifier ':' TypeSpec ';'
      

ENUM Section. Contains enum declarations.

     EnumSection        <- 'ENUM SECTION.' EnumDecl+ 'END ENUM SECTION.'
     EnumDecl           <- Identifier ':' EnumMemberList ';'
     EnumMemberList     <- Identifier (',' Identifier)*

ASSERT Section. Contains assertions.

     AssertionSection   <- 'ASSERT SECTION.' AssertDecl+ 'END ASSERT SECTION.'
     AssertDecl         <- 'ASSERT' Expression (':' StringLiteral)? ';'

## Code Division (Optional)
Statements: Structured and Oberon-like, but adapted to Xenober16’s flavor.

     CASE key OF
         'A'..'Z': SAY "letter";
         DIGITS: SAY "digit";    // using a macro of a Range here
     ELSE
         SAY "other";
     END CASE;

Grammar:

     CodeDiv           <- 'CODE DIVISION.' ProcDecl+ 'END CODE DIVISION.'
     ProcDecl          <- Pragma* 'PROC' Identifier '(' ParamList? ')' ';' 
                          Block
                          'END' Identifier ';'
     ParamList         <- Param (',' Param)*
     Param             <- Identifier ':' TypeSpec (':=' ConstExpr)?
  
     Block             <- Statement*
     Statement         <- Assignment
                        / IfStmt
                        / CaseStmt
                        / LoopStmt
                        / ProcCall
                        / SystemCall
                        / ';'   # empty stmt allowed   

     Assignment        <- Identifier ':=' Expression ';'
     ProcCall          <- Identifier '(' ArgList? ')' ';'
     ArgList   <- NamedArg (',' NamedArg)*
     NamedArg  <- Identifier ':=' Expression

     SystemCall        <- QualIdent '(' ArgList? ')' ';'   
  
     IfStmt            <- 'IF' ExprStmt ( 'ELSIF' ExprStmt )* ( 'ELSE' Statement+ )? 'END IF;'
     ExprStmt          <- Expression 'THEN' Statement+
     CaseStmt          <- 'CASE' Expression 'OF' CaseBranch+ ( 'ELSE' Statement+ )? 'END CASE;'
     CaseBranch        <- (Literal / SimpleRange) ':' Statement+
     Literal           <- Number / HexLiteral / StringLiteral
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
     QualIdent         <- Identifier ('.' Identifier)*
     Primary           <- '-' Primary
                        / Number
                        / StringLiteral
                        / QualIdent
                        / '(' Expression ')'

# Standard Libraries for System-level resources

* SYS: kernal calls e.g. SYS.CHROUT(c);  Also, clock access e.g. SYS.CLK.
* REG: read and write the 16 pseudo-register words, also by Low and High bytes.  Also read access to CPU regs.
* MEM: peek values, and poke one or a list of values.

* Writing to CPU Registers requires the use of inline assembly.
 
# Bitfields

* Defined using the @BITFIELD(width) annotation within records.
* Can define fields from 1 to 15 bits long.
* Example: value : @BITFIELD(12);
* Bitfields are implicitly unsigned integral types.

The compiler infers the underlying type based on the width:

     @BITFIELD(1) - @BITFIELD(8): Uses one byte
     @BITFIELD(9) - @BITFIELD(15): Uses two bytes

Compiler generates code to handle masking and shifting.

# Grammar Notes

* Constant expressions are always folded at compile time, including bitwise ops, math, and field offsets.
* Pragmas attach to var-decl or proc-decl. Store these in the AST as a list of symbols and optional values.
* Procedure "overloading" is resolved by mangling names based on the parameter types — ASTBuilder will handle this during symbol table construction or codegen.
* Inline procs are simply procedure literals, no captures — just wrap in a small ProcLiteralNode with an anonymous name.

* Separate Grammar Files: Each division (Module Header, Metadata, Import, Macro, Memory, Data, Code, Expressions) will have its own .rakumod file (e.g., MyLanguage::Grammar::ModuleHeader.rakumod).
* Expressions Grammar: A separate Expressions grammar will be created and used by both the Data and Code divisions for parsing expressions.
* is export: The is export trait will be used extensively in the Expressions grammar to make common expression tokens (e.g., identifier, number, string_literal) available in other grammars without qualification.
* use ... only (...): This construct will be used to import specific tokens/rules from other division grammars when needed, minimizing namespace pollution.
* Roles: Roles will be used to define and reuse common grammar fragments that are not tied to a specific division.

