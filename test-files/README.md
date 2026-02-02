# Xenober16 Test Suite

This directory contains a comprehensive test suite for the Xenober16 language, organized into three focused test suites that share common test resources. Each suite isolates a different layer of the compiler pipeline, enabling efficient debugging and preventing cascading issues.

## Directory Organization

```
test-files/
├── common/          # Shared test case files (all suites use these)
│   ├── test-*.xen   # Comprehensive test cases (test-0 through test-16)
│   └── expected-p8/ # Expected Prog8 output for transpiler validation
├── grammar/         # Parser grammar tests (parse-only, no ASTBuilder)
├── ast/             # ASTBuilder semantic tests (parse + AST validation)
├── transpiler/      # Transpiler tests (full pipeline to Prog8)
└── interpreter/     # Interpreter tests (program execution)
```

## Test Suites

### common/ - Shared Test Resources
**All test files are here for use by all three test suites.** This ensures a single source of truth.

**Contents:**
- `test-0-minimal.xen` through `test-16-enum.xen` - Comprehensive feature tests covering all grammar rules
- `expected-p8/` - Expected Prog8 outputs for transpiler validation

### 1. **grammar/** - Parser Grammar Tests
Tests **only** the parsing of the Xenober16 grammar. These tests verify that the grammar correctly accepts valid syntax **without** running the ASTBuilder.

**Contents:**
- `debug-parse.raku` - Debug script for individual grammar rule testing
- References `common/*.xen` test files

**Testing approach:** Parse files with grammar only (no `:actions`), validate parse success/failure

**Run tests:**
```bash
raku grammar/debug-parse.raku
```

### 2. **ast/** - ASTBuilder Tests  
Tests the semantic layer—verifying that parse trees are correctly transformed into well-formed Abstract Syntax Trees with proper node relationships and attributes.

**Contents:**
- `debug-call.raku`, `debug-expr.raku`, `debug-rep.raku`, `debug-sum.raku` - AST debugging scripts
- References `common/*.xen` test files

**Testing approach:** Parse files with `:actions(ASTBuilder)`, validate AST structure and attributes

**Run tests:**
```bash
# AST validation test runner (create similar to transpiler runner)
```

### 3. **transpiler/** - Transpiler Tests
Tests the complete transpilation pipeline from Xenober16 source code to Prog8 output. Validates output against expected files.

**Contents:**
- `test-transpiler.raku` - Main transpiler test runner
- `transpile-prog8.raku` - Utility script for transpiling files
- References `common/*.xen` test files and `common/expected-p8/` for output validation

**Testing approach:** Parse + AST + transpile, compare output to expected files

**Run tests:**
```bash
raku transpiler/test-transpiler.raku
```

### 4. **interpreter/** - Interpreter Tests
Tests the interpreter/execution layer. Verifies that the interpreter correctly executes Xenober16 programs.

**Contents:**
- `xenober-test.raku` - Interpreter test runner
- References `common/*.xen` test files for execution validation

**Testing approach:** Parse + AST + interpret, validate execution results

**Run tests:**
```bash
raku interpreter/xenober-test.raku
```

## Test Workflow

When a test fails, the layered suite structure tells you exactly where to look:

1. **Grammar test fails** → Grammar rule is broken
2. **Grammar passes, AST test fails** → ASTBuilder is broken
3. **AST passes, transpiler test fails** → Prog8Transpiler is broken
4. **Transpiler passes, interpreter test fails** → Interpreter is broken

This **isolation prevents cascading refactorings** where fixing one layer accidentally breaks another.

---

## Test Files Overview (Original Documentation)

### test-0.xen - Minimal Program
**Purpose**: Tests the absolute minimum valid program structure.
**Features Tested**:
- MODULE IDENTIFICATION DIVISION
- MODULE-ID, AUTHOR, DESCRIPTION metadata
- MODULE END terminator

**What to Verify**: Program parses successfully with just the metadata sections.

---

### test-1.xen - Simple Output
**Purpose**: Tests basic variable usage and output.
**Features Tested**:
- DATA DIVISION with variable declarations
- uint8 type
- Assignment operator (:=)
- SAY statement for output
- String literals
- MAIN DIVISION

**What to Verify**: Variables can be declared, assigned, and output correctly.

---

### test-2.xen - Expressions
**Purpose**: Tests arithmetic expressions and operator precedence.
**Features Tested**:
- Arithmetic operators (+, -, *)
- Operator precedence (multiplication before addition)
- Parenthesized expressions
- Multiple operations in sequence

**What to Verify**: Expressions evaluate correctly with proper precedence.

---

### test-3.xen - Conditionals
**Purpose**: Tests conditional branching and comparison operators.
**Features Tested**:
- IF/THEN/ELSIF/ELSE/END structure
- Comparison operators (>, >=, <, <=, ==)
- Hexadecimal literals ($65)
- Nested conditionals
- Multiple ELSIF branches

**What to Verify**: Conditionals branch correctly based on comparisons.

---

### test-4.xen - Loops
**Purpose**: Tests loop constructs.
**Features Tested**:
- WHILE/DO/END loops
- REPEAT/UNTIL loops
- Loop control with conditionals
- Accumulator patterns

**What to Verify**: Loops execute the correct number of times and terminate properly.

---

### test-5.xen - CASE Statements
**Purpose**: Tests the CASE statement with various selector types.
**Features Tested**:
- CASE/OF/END structure
- Single value selectors
- Multiple value selectors (comma-separated)
- Range selectors (1..10)
- ELSE clause for default case
- Vertical bar (|) branch separators

**What to Verify**: CASE statements match correct branches for values, ranges, and defaults.

---

### test-6.xen - Procedures
**Purpose**: Tests procedure definitions and calls.
**Features Tested**:
- PROCEDURE DIVISION
- PROC declarations with parameters
- Parameter type specifications
- Procedure calls with arguments
- Multiple procedures in same program
- Variable scope between procedures and main

**What to Verify**: Procedures can be defined, called with parameters, and execute correctly.

---

### test-7.xen - Constants
**Purpose**: Tests constant definitions and usage.
**Features Tested**:
- CONSTANTS DIVISION
- Constant declarations with initialization
- Using constants in expressions
- String constants
- Constants in conditionals

**What to Verify**: Constants are properly initialized and can be referenced throughout the program.

---

### test-8.xen - Memory Areas
**Purpose**: Tests memory area declarations for Commander X16.
**Features Tested**:
- MEMORY DIVISION
- AREA declarations
- RAM(address) syntax
- BANK(bank, address) syntax
- SIZE specifications
- Hexadecimal addresses

**What to Verify**: Memory areas parse correctly and can be referenced in the program.

---

### test-9.xen - Advanced/Comprehensive
**Purpose**: Tests multiple features working together in a realistic program.
**Features Tested**:
- All division types in one program
- Short-form metadata (ID:, WHO:, WHAT:)
- Multiple procedures with various parameter counts
- Constants used in logic
- Memory areas for hardware interaction
- Loops calling procedures
- CASE statements inside procedures
- Complex conditional logic

**What to Verify**: All features integrate properly and work together without conflicts.

---

## Running the Tests

To run a test:
```bash
raku -Ilib xen16.raku test-files/test-0.xen
```

## Test Progression

The tests are designed to be run in order:
1. Start with test-0 to verify basic parsing
2. Progress through each test sequentially
3. Each test adds complexity while building on previous features
4. test-9 combines everything for a comprehensive validation

## Adding New Tests

When adding new language features:
1. Add basic feature tests to the appropriate level
2. Update test-9 to include the new feature in combination with others
3. Update this README with the new feature coverage
4. Ensure tests conform to current grammar specification

## Grammar Conformance

All tests conform to the current Xenober16 grammar specification:
- MODULE IDENTIFICATION DIVISION with MODULE-ID, AUTHOR, DESCRIPTION
- Optional CONSTANTS DIVISION for immutable values
- Optional MEMORY DIVISION for Commander X16 memory areas
- Optional DATA DIVISION for variables
- Optional PROCEDURE DIVISION for procedures
- Optional MAIN DIVISION for main program logic
- MODULE END as terminator

Key syntax elements:
- Assignment: `:=`
- Type annotations: `name: type`
- CASE branches: `| selector: statement`
- Ranges: `1..10`
- Hex literals: `$a000`
