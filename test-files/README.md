# Xenober16 Test Suite

This directory contains a progressive test suite for the Xenober16 language, designed to test features incrementally from simplest to most complex.

## Test Files Overview

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
