unit class Xenober15::ASTBuilder;

use Xenober15::Builder::NodeFactory;

method trace($msg) {        # to control the debug output
    say $msg;
}

method TOP($/) {
   make {
   	   type   	  	   => 'program',
       identification => $<identification-division>.made,
       data           => $<data-division>:exists ?? $<data-division>.made !! Nil,
       procedure      => $<procedure-division>:exists ?? $<procedure-division>.made !! Nil
   };
}

method identification-division($/) {
    make {
        type => "identification",
        name => ~$<program-id><identifier>,
        #date => ~$<program-date><identifier>,
        #designer => ~$<designed-by><identifier>
    };
}

method data-division($/) {
    make {
        type => "data",
        storage => $<working-storage-section>:exists ?? $<working-storage-section>.made !! Nil
    };
}

method working-storage-section($/) {
    make $<declaration>».made
}

method declaration($/) {
    #self.trace("Parsing declaration: [" ~ $<identifier> ~ "] of type [" ~ ~$<data-type> ~ "]");
    if !$<data-type> {
        die "Declaration must have a data type";
    }
    make {
        identifier => ~$<identifier>,
        data_type  => ~$<data-type>
    };
}

method procedure-division($/) {
    make {
        type => "procedure",
        statements => $<statement>».made
    };
}

method statement($/) {
	make $/.values[0].made;
}

method assignment($/) {
    make {
        type  => "assignment",
        name  => ~$<identifier>,
        value => $<expression>.made
    };
}

method say($/) {
    if !$<expression> {
        die "SAY statement must have an expression";
    }
    make Xenober15::Builder::NodeFactory.make-say($/);
}

method expression($/) {
    if $<string-literal> {
        my $raw = ~$<string-literal>;
        my $str = $raw.substr(1, $raw.chars - 2); # remove quotes
        make { type => "string-literal", value => $str };
    } 
    elsif $<compare-expr> {
        make $<compare-expr>.made;
    }
    elsif $<arith-expr> {
        make $<arith-expr>.made;
    } 
#       elsif $<number> {
        #make { type => "number", value => +$<number> };
#       } 
    elsif $<identifier> {
        make { type => "identifier", name => ~$<identifier> };
    }
}

method arith-expr($/) {
    if !$<term> {
        die "Arithmetic expression must have at least one term";
    }
    if $<add-op> && $<add-op>.elems != $<term>.elems - 1 {
        die "Number of add operators must be one less than number of terms";
    }
    my $lhs = $<term>[0].made;
    for $<add-op>.kv -> $i, $op {
        my $rhs = $<term>[$i + 1].made;
        $lhs = make {
            type => "binop",
            op   => ~$op,
            lhs => $lhs,
            rhs => $rhs
        };
    }
    make $lhs;
}

method term($/) {
    if !$<factor> {
        die "Term must have at least one factor";
    }
    my $lhs = $<factor>[0].made;
    for $<mul-op>.kv -> $i, $op {
        my $rhs = $<factor>[$i + 1].made;
        $lhs = make {
            type => "binop",
            op   => ~$op,
            lhs => $lhs,
            rhs => $rhs
        };
    }
    make $lhs;
}

method factor($/) {
    if !$<number> && !$<identifier> && !$<arith-expr> {
        die "Factor must be a number, identifier, or arithmetic expression";
    }
    if $<number> {
        if $<number><digit-string> {
            #self.trace("Parsing number as digit string: " ~ ~$<number><digit-string>);
            make { type => "number", value => +$<number><digit-string>, base => 10 };
        }
        elsif $<number><hex-string> {
            my $hexval = $<number><hex-string>.Str.substr(1).parse-base(16);
            #self.trace("Parsing number as hex string: " ~ ~$<number><hex-string> ~ " (value: " ~ $hexval ~ ")");
            make { type => "number", value => $hexval, base => 16 };
        }
    } 
    elsif $<identifier> {
        make { type => "identifier", name => ~$<identifier> };
    } 
    elsif $<arith-expr> {
        make $<arith-expr>.made;
    }
}

method compare-expr($/) {
    if !$<arith-expr> || $<arith-expr>.elems != 2 {
        die "Comparison expression must have exactly two arithmetic expressions";
    }
    if !$<compare-op> {
        die "Comparison expression must have a comparison operator";
    }
    if $<compare-op> {
        make {
            type => "compare",                   
            lhs  => $<arith-expr>[0].made,
            op   => ~$<compare-op>,
            rhs  => $<arith-expr>[1].made
        };
    } else {
        make $<arith-expr>[0].made; # No comparison, just return the first expression
    }
}

######################################################################
#
# Xenober-16 control flow statements
#
######################################################################
method statement-sequence($/) {
    make $<statement>».made;
}

method if-statement($/) {
    if !$<expression> {
        die "IF statement must have a condition";
    }
    if !$<statement-sequence> {
        die "IF statement must have a statement sequence";
    }
    if !$<end-token> {
        die "IF statement must end with END";
    }
    if !$<then-token> {
        die "IF statement must have a THEN token";
    }
    my $elsif = $<elsif-clause>:exists ?? $<elsif-clause>».made !! [];
    my $else  = $<else-clause>:exists  ?? $<else-clause>.made   !! Nil;
    # Create the AST node for the if statement
    #self.trace("Building IF AST with condition: " ~ ~$<expression>);
    make {
        type => "if",
        condition => $<expression>.made,
        then => $<statement-sequence>.made,
        elsif => $elsif,
        else => $else
    };
}

method elsif-clause($/) {
    if !$<expression> {
        die "ELSIF clause must have a condition";
    }
    if !$<statement-sequence> {
        die "ELSIF clause must have a statement sequence";
    }
    if !$<then-token> {
        die "ELSIF clause must have a THEN token";
    }
    make {
        type => "elsif",
        condition => $<expression>.made,
        then => $<statement-sequence>.made
    };
}

method else-clause($/) {
    if !$<statement-sequence> {
        die "ELSE clause must have a statement sequence";
    }
    make {
        type => "else",
        statements => $<statement-sequence>.made
    };
}

method while-statement($/) {
    if !$<expression> {
        die "WHILE statement must have a condition";
    }
    if !$<statement-sequence> {
        die "WHILE statement must have a statement sequence";
    }
    if !$<end-token> {
        die "WHILE statement must end with END";
    }
    if !$<do-token> {
        die "WHILE statement must have a DO token";
    }
    #self.trace("Building WHILE AST with condition: " ~ ~$<expression>);
    make {
        type => "while",
        condition => $<expression>.made,
        body => $<statement-sequence>.made
    };
}

method repeat-statement($/) {
    if !$<statement-sequence> {
        die "REPEAT statement must have a statement sequence";
    }
    if !$<until-token> {
        die "REPEAT statement must have an UNTIL token";
    }
    if !$<expression> {
        die "REPEAT statement must have a condition";
    }
    #self.trace("Building REPEAT UNTIL " ~ $<expression>);
    make {
        type => "repeat",
        body => $<statement-sequence>.made,
        condition => $<expression>.made
    };
}

method for-statement($/) {
    if !$<identifier> {
        self.trace( "FOR statement must have a variable identifier" );
    }
    if !$<expression>[0] {
        self.trace(  "FOR statement must have a start expression" );
    }
    if !$<expression>[1] {
        self.trace(  "FOR statement must have an end expression" );
    }
    if !$<do-token> {
        self.trace(  "FOR statement must have a DO token" );
    }
    if !$<statement-sequence> {
        self.trace(  "FOR statement must have a statement sequence" );
    }
   
    my $by-expr = $<expression>[2]:exists ?? $<expression>[2].made !! Nil;
    
    make {
        type => "for",
        variable => ~$<identifier>,
        start => $<expression>[0].made,
        end => $<expression>[1].made,
        step => $by-expr,  # Nil if not provided
        body => $<statement-sequence>.made
    };
}

method case-statement($/) {

    say( "\n\n\n         **** TODO **** The labels aren't being parsed correctly yet.\n\n\n");

    my $expr = $<expression>.ast;
    my @cases = $<case-element>.map(*.ast);
    my @else = $<else-token> ?? $<statement-sequence><statement>.map(*.ast) !! Nil;
    
    make {
        type => "case",
        expr => $expr,
        cases => @cases,
        else => @else
    }
}

method case-element($/) {
    my @labels = $<label-list>».made;
    my @body = $<statement-sequence><statement>.map({ $_.ast });
    
    make {
        type => "case-element",
        labels => @labels,
        body => @body
    };
}



