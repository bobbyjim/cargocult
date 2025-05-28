unit class Xenober16::ASTBuilder;

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
            name => ~$<identifier>
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
        make {
            type  => "say",
            value => $<expression>.made
        };
    }
    
    method expression($/) {
        if $<string-literal> {
            my $raw = ~$<string-literal>;
            my $str = $raw.substr(1, $raw.chars - 2); # remove quotes
            make { type => "string", value => $str };
        } 
        elsif $<compare-expr> {
            make $<compare-expr>.made;
        }
        elsif $<arith-expr> {
            make $<arith-expr>.made;
        } 
        elsif $<literal> {
            make { type => "literal", value => +$<literal> };
        } 
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
        if !$<literal> && !$<identifier> && !$<arith-expr> {
            die "Factor must be a literal, identifier, or arithmetic expression";
        }
        if $<literal> {
            make { type => "literal", value => +$<literal> };
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
                type => "binop",                    # or "compare" could be used here?
                lhs  => $<arith-expr>[0].made,
                op   => ~$<compare-op>,
                rhs  => $<arith-expr>[1].made
            };
        } else {
            make $<arith-expr>[0].made; # No comparison, just return the first expression
        }
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

    method statement-sequence($/) {
        make $<statement>».made;
    }

