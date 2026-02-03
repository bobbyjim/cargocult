# Grammar Updates Summary

## Files Updated
- `doc/GRAMMAR-UPDATED.md` - Complete updated grammar reference
- `doc/Grammar-Updated.ebnf` - Complete updated EBNF specification

## Major Changes from Previous Documentation

### 1. Comments (NEW)
- **Added**: Line comments with `//` syntax
- **Impact**: Comments can now appear anywhere whitespace is allowed
- **Location**: Whitespace token override in Grammar.rakumod

### 2. Macro Division (ENHANCED)
- **Added**: Function-like macros with `META` keyword
  ```
  META functionName(param1: type1, param2: type2) : ReturnType
  BEGIN
      ... statements ...
  END functionName;
  ```
- **Kept**: Simple macro syntax for value macros
  ```
  CONSTANT_NAME: MacroType IS expression;
  ```
- **Impact**: Macros can now contain full procedural code, not just expressions

### 3. Return Statements (NEW)
- **Added**: `RETURN expression;` as a valid statement
- **Impact**: Function-like macros and procedures can now explicitly return values
- **Location**: Added to simple-statement rule

### 4. Function Calls in Expressions (ENHANCED)
- **Added**: Support for function/macro calls in expression contexts
  ```
  result := clamp(x, 0, 100);  // Function call as RHS of assignment
  y := max(a, b) + 5;          // Function call in arithmetic
  ```
- **Impact**: Designators now support selector syntax `func(args)`
- **Location**: Updated selector token to include `"(" [ArgumentList] ")"`

### 5. Bank Access Syntax (FIXED)
- **Changed**: Corrected token usage in bank-access rule
- **Before**: `BANK '(' <expression> ')' '[' <expression> ']'`
- **After**: `BANK <OPEN_PAREN> <expression> <CLOSE_PAREN> '[' <expression> ']'`
- **Impact**: Consistent token usage throughout grammar

## No Changes Needed For

### Already Documented
- Variable declarations (VAR keyword requirement was already in docs)
- Array syntax with `array[n] of type`
- Memory divisions and RAM/BANK areas
- All control flow statements (IF/WHILE/FOR/REPEAT/CASE)
- Enum declarations with brace syntax
- Procedure definitions with FN keyword

## Test Coverage
All 25 test files now pass with the updated grammar:
- ✅ Comments in code (test-simple.xen)
- ✅ Macros with META keyword (test-12-MACRO.xen)
- ✅ Memory areas and bank access (test-13-memory-areas.xen)
- ✅ All other existing features

## Recommendation
Replace the old documentation files:
- `doc/Grammar.ebnf` → `doc/Grammar-Updated.ebnf`
- `doc/GRAMMAR.md` → `doc/GRAMMAR-UPDATED.md`

Or keep both versions if you want to track the evolution of the grammar.
