# Expanded Raku grammar for Cult without parentheses in control flow

grammar Cult {
    # Start symbol - the entire source code
    rule TOP {
        ^ <statements> $
    }

    # Statements can be multiple types: function declarations, blocks, and expressions
    rule statements {
        <statement>*
    }

    # A statement can be a function declaration, block, or a special construct (asm, include, etc.)
    rule statement {
        <function-declaration>
        | <variable-declaration>
        | <assignment>
        | <expression>
        | <if-statement>
        | <while-loop>
        | <block>
        | <include-declaration>
        | <asm-declaration>
        | <s16-declaration>
    }

    # Function declaration format
    rule function-declaration {
        'function' <identifier> '(' <parameter-list> ')' ':' <type> <block>
    }

    # Parameter list (optional)
    rule parameter-list {
        [ <parameter> ]*
    }

    rule parameter {
        <identifier> ':' <type>
    }

    # A function's block (enclosed in curly braces)
    rule block {
        '{' <statements> '}'
    }

    # Variable declaration
    rule variable-declaration {
        'var' <identifier> ':' <type>
    }

    # Assignment format (e.g., score = 10;)
    rule assignment {
        <identifier> '=' <expression>
    }

    # Expressions (can be simple values or more complex arithmetic)
    rule expression {
        <term> [ '+' <term> | '-' <term> ]*
    }

    # Term (handles multiplication and division)
    rule term {
        <factor> [ '*' <factor> | '/' <factor> ]*
    }

    # Factor (either numbers, identifiers, or parentheses for grouping)
    rule factor {
        <number> | <identifier> | '(' <expression> ')'
    }

    # Number (an integer or unsigned integer)
    rule number {
        \d+
    }

    # If statement (no parentheses around the condition)
    rule if-statement {
        'if' <expression> <block> [ 'else' <block> ]?
    }

    # While loop (no parentheses around the condition)
    rule while-loop {
        'while' <expression> <block>
    }

    # Include file declaration format
    rule include-declaration {
        'include' '{' <identifier>+ '}'
    }

    # Inline assembly block (raw 6502 assembly)
    rule asm-declaration {
        'asm' '{' <asm-line>+ '}'
    }

    rule asm-line {
        <any>+  # Match any characters for inline assembly code
    }

    # Sweet16-like pseudo-assembly block
    rule s16-declaration {
        's16' '{' <s16-line>+ '}'
    }

    rule s16-line {
        <any>+  # Match any characters for Sweet16-like pseudo-assembly code
    }

    # Identifier is a word that starts with a letter or underscore, followed by letters, digits, or underscores
    # Identifier for field names, e.g., "flag1"
    rule identifier {
        \w+
    }

    # Types used in the language
    rule type {
        'uint1' | 'uint2' | 'uint3' | 'uint4' | 'uint5' | 'uint6' | 'uint7' | 'uint8' 
        | 'uint9' | 'uint10' | 'uint11' | 'uint12' | 'uint13' | 'uint14' | 'uint15' | 'uint16'
        | 'uint32' | 'int8' | 'int16' | 'int32' | 'char'   # Regular integer types
    }

    rule struct {
        'struct' <identifier> '{' <struct-field>+ '}'
    }

    rule struct-field {
        <identifier> ':' <type>   # Use colon for bitfields with type size
    }
}
