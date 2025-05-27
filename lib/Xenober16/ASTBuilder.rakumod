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
            storage => $<working-storage-section>.made
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
