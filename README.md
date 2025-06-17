# I. Xenober16
A language custom-built for the Commander X16, intentionally blending "retro" aesthetics with modern programming principles.
Inspired by Oberon's readability and structure combined with COBOL's division-based organization.
Focus on direct hardware access, explicit memory management, and efficient code generation optimized for the X16's 6502 processor.

I'm building a structured intermediate representation with a clean front-end, and using the interpreter for testing and prototyping behavior. Then, for real deployment, the code generators will produce trusted outputs (C, Prog8) to do the heavy lifting for optimization and linking.

# II. Language Structure

The language follows a rigid division-based structure:

## MODULE IDENTIFICATION DIVISION: (Mandatory)
    MODULE-ID. (Mandatory): Designates the module name.
    MAIN. (Optional): Marks the program's entry point.
    AUTHOR. (Optional)
    DATE-WRITTEN. (Optional)
    DESCRIPTION. (Optional)
    LICENSE. (Optional)

## IMPORT DIVISION: (Optional)
USE statements (one per line): Declares module dependencies.

## DATA DIVISION: (Optional)
WORKING-STORAGE SECTION. (Mandatory): Contains variable and type declarations.

* Oberon-style syntax for declarations (e.g., variableName : DataType := initialValue;).
* Type definitions (records, arrays) are also located in this section.

## CODE DIVISION: (Optional)
* Contains executable code.
* Oberon-style syntax for procedures and the main program body.
* BEGIN and END keywords mark the start and end of procedures.
* The END tag does not include the MODULE-ID.
* No BEGIN keyword is used to demarcate the start of the main program body.

# III. Data Types
* Signed Integers: INT8, INT16, INT24.
* Unsigned Integers: UINT8, UINT16, UINT24.
* Character: CHAR (8-bit).
* Fixed-Point: A FIXED type is under consideration, potentially with bit-length specifiers.
* Arrays: Statically sized arrays.
* Records (Structures): Used for grouping data.
* Pointers: Supported for memory manipulation. Restricted pointers may be used.

# IV. Memory Management
Annotations: Used to specify memory locations for variables.

* @BANK(bankNumber, address): Places the variable in banked RAM.
* @RAM(address): Places the variable in directly addressable RAM ("golden RAM").
* @ZEROPAGE(offset): Places the variable in zero page at the given offset.

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
* Example: value : @BITFIELD(12);
* Bitfields are implicitly unsigned integral types.

The compiler infers the underlying type based on the width:
    @BITFIELD(1) - @BITFIELD(8): Implies UINT8
    @BITFIELD(9) - @BITFIELD(16): Implies UINT16
    @BITFIELD(17) - @BITFIELD(24): Implies UINT24

Compiler generates code to handle masking and shifting.

# IX. Control Flow:

* IF-THEN-ELSE, WHILE, FOR loops.
* CASE statements (optional).
* No GOTO. LOOP and EXIT (optional).

# X. Modules and Imports:

* Modules are defined using the division structure (MODULE-ID serves as the module name).
* Modules are imported using the USE keyword in the IMPORT DIVISION.
* Exported members are denoted with a * at the end of the name
* To call a method in another module, specify the namespace e.g. OtherModule.AMethod()
* The compiler enforces namespace qualifications.

# XI. MAIN Module:

* One module per program must be designated the MAIN module with the MAIN. annotation.
* That module contains the program's entry point in a procedure Main()
* The MAIN module is also where global variables are declared.

# XII. Inline Assembly:

Allows embedding 6502 assembly code directly within the language.

# XIII. Exclusions:

* No sets.
* No real numbers (floating-point).
* No dynamic memory allocation (NEW, MALLOC, FREE, DISPOSE).
* No standalone Boolean Type.
