# Xenober16 to Prog8 Transpiler - Test Suite

This directory contains the test suite for the Xenober16 to Prog8 transpiler.

## Running Tests

### Run all tests:
```bash
raku test-transpiler.raku
```

### Run with verbose output:
```bash
raku test-transpiler.raku --verbose
```

### Run specific test(s):
```bash
raku test-transpiler.raku --only=FOR
raku test-transpiler.raku --only=comprehensive
```

### Update expected outputs:
```bash
raku test-transpiler.raku --update
```

## Transpiling Individual Files

### To stdout:
```bash
raku transpile-prog8.raku test-files/test-14-comprehensive-2.xen
```

### To file:
```bash
raku transpile-prog8.raku test-files/test-14-comprehensive-2.xen output.p8
```

### Using xen16 directly:
```bash
raku -I lib xen16.raku --transpile=prog8 test-files/test-14-comprehensive-2.xen
```

## Test Coverage

The test suite includes **18 test files** covering:

### Basic Features
- **test-0-minimal.xen** - Minimal valid program structure
- **test-1-variables.xen** - Variable declarations and basic types
- **test-2-operators.xen** - Binary operators (+, -, *, /, MOD, =, <>, <, >, etc.)
- **test-2a-arrays.xen** - Array declarations and access

### Control Flow
- **test-3-IF.xen** - IF/THEN/ELSE and ELSIF branches
- **test-4-WHILE.xen** - WHILE loops
- **test-10-FOR.xen** - FOR loops with ranges and steps
- **test-5-CASE.xen** - CASE statements with ranges and multiple selectors

### Procedures
- **test-6-PROC.xen** - Procedure definitions, calls, and parameters

### Data & Constants
- **test-7-CONSTANTS.xen** - Constant declarations
- **test-16-enum.xen** - Enumeration types

### Memory Management
- **test-8-MEMORY.xen** - Direct memory access
- **test-13-memory-areas.xen** - Memory area declarations (RAM/BANK)
- **test-11-BITFIELD.xen** - Bitfield operations

### Advanced Features
- **test-12-MACRO.xen** - Macro division (preprocessing)
- **test-15-module-parameters.xen** - Module parameterization

### Comprehensive Tests
- **test-9-comprehensive-1.xen** - Complex multi-feature integration
- **test-14-comprehensive-2.xen** - FOR loops + memory areas + procedures

## Test Results (Latest Run)

✅ **18/18 tests passing** (100%)

## Prog8 Output Format

The transpiler generates valid Prog8 code with:

### Module Structure
- Module names converted to lowercase
- Header comments with source metadata
- Proper block scoping with `{ }`

### Type Mappings
- `uint8` → `ubyte`
- `uint16` → `uword`
- `int8` → `byte`
- `int16` → `word`
- `char` → `ubyte`
- `string` → `str`

### Statement Mappings
- `SAY "text"` → `txt.print("text")` + `txt.nl()`
- `ECHO "text"` → `txt.print("text")`
- `FOR i := 0 TO 10` → `for i in 0 to 10`
- `WHILE cond DO` → `while cond {`
- `REPEAT ... UNTIL cond` → `repeat { } until cond`
- `IF/ELSIF/ELSE` → `if/else if/else`
- `CASE OF` → `when {`

### Memory Areas
- `AREA screen RAM($0400) SIZE 1000` → `&uword screen = $0400  ; size: 1000`
- `@screen[i]` → `screen[i]`
- Direct memory refs → `@(addr)` syntax

### Operators
- `=` → `==` (equality)
- `<>` → `!=` (inequality)
- `MOD` → `%`
- `DIV` → `/`
- `&` → `+` (string concatenation)

## Known Issues

1. One warning in test-12-MACRO.xen: "Unhandled statement type: VarDeclNode" - appears to be a local variable declaration inside main that should be handled differently
2. Multi-level module imports not yet tested
3. Record types not yet fully implemented in transpiler

## Future Enhancements

- [ ] Add test for nested procedures
- [ ] Add test for copy-out parameter semantics
- [ ] Add test for RETURN values
- [ ] Add error handling tests (malformed input)
- [ ] Add test for complex expressions
- [ ] Add test for string concatenation
- [ ] Performance benchmarks
- [ ] Integration tests with actual Prog8 compiler

## Directory Structure

```
test-files/
  ├── test-*.xen              # Xenober16 source files
  └── expected-p8/
      └── test-*.p8           # Expected Prog8 output
```
