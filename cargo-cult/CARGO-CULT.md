# Cargo Cult Project: Compiler for the X16

## Current Goals

1. **Core Objective**: Create a domain-specific language (DSL) to simplify programming for the X16.
2. **Guiding Principles**:
    - Learn from C and Pascal's mistakes.
    - Tailor the syntax to the X16's unique constraints and opportunities.
    - Enable elegant handling of structures, bitfields, and namespaces.
    - Ensure ease of use for projects like X16 Terrarium.

3. **Initial Scope**:
    - Implement namespaces (`cargo` blocks) that flatten into C-like symbols.
    - Support structures and bitfields for low-level programming.
    - Transpile to Prog8, leveraging its focus on 6502 programming.

---

## Implementation Plan

### Grammar
```raku
grammar CargoCultGrammar {
    rule TOP        { <statement>* }
    rule statement  { <namespace> | <struct> | <assignment> | <expression> }

    rule namespace  { 'cargo' <identifier> '{' <statement>* '}' }
    rule struct     { 'struct' <identifier> '{' <member>* '}' }
    rule member     { <type> <identifier> ['[' <number> ']']? ';' }

    rule assignment { <identifier> '=' <expression> ';' }
    rule expression { <term> [<operator> <term>]* }
    
    rule term       { <identifier> | <number> | 'random(' <expression> ')' }
    rule operator   { '+' | '-' | '*' | '/' }

    token identifier { \w+ }
    token type       { 'uint' <number> }
    token number     { \d+ }
}
```

### Actions
```raku
class CargoCultActions {
    method TOP($/)      { make $<statement>>>.made } 
    method namespace($/) {
        my $name = $<identifier>.Str;
        my $statements = $<statement>>>.made;
        make { type => 'namespace', name => $name, statements => $statements };
    }

    method struct($/) {
        my $name = $<identifier>.Str;
        my $members = $<member>>>.made;
        make { type => 'struct', name => $name, members => $members };
    }

    method member($/) {
        my $type = $<type>.Str;
        my $name = $<identifier>.Str;
        my $size = $<number> ?? $<number>.Str !! Nil;
        make { type => $type, name => $name, size => $size };
    }

    method assignment($/) {
        make { type => 'assignment', variable => $<identifier>.Str, value => $<expression>.made };
    }

    method expression($/) {
        make $<term>>>.made;
    }

    method term($/) {
        if $<identifier> {
            make { type => 'identifier', value => $<identifier>.Str };
        } elsif $<number> {
            make { type => 'number', value => $<number>.Str };
        } elsif $<expression> {
            make { type => 'function', name => 'random', args => $<expression>.made };
        }
    }
}
```

---

### Example Code
```cargo
cargo biochem {
    struct molecule {
        uint8 type;
        uint16 mass;
        uint1 flags[8];
    };

    var drives: array[10] of uint8;
}

program {
    biochem.drives[0] = random(256);
}
```

---

### Output Transpilation
Translates into Prog8-like syntax:
```prog8
biochem_drives[0] = random(256);
```

---

### To Do
1. Write Raku tests for grammar and actions.
2. Implement transpiler logic for Prog8 output.
3. Define error handling for invalid input.
4. Test with increasingly complex examples.
