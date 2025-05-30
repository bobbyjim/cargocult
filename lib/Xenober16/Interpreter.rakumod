unit class Xenober16::Interpreter;

has %!env;  # Symbol table for variables

method trace($msg) {        # to control the debug output
    say $msg;
}

# Entry point
method run($ast) {
    self.handle-program($ast);
}

# Handles top-level program node
method handle-program($program) {
    self.handle-identification($program<identification>) if $program<identification>;
    self.handle-data($program<data>)                     if $program<data>;
    self.handle-procedure($program<procedure>)           if $program<procedure>;
}

method handle-identification($id) {
    self.trace( "Program Name: " ~ $id<name> );
}

method handle-data($data) {
    for $data<storage>.flat -> $decl {
        my $name = $decl<identifier>;
        my $type = $decl<data_type>;
		self.trace( " - Declaring variable: $name of type $type" );
        # You could initialize based on $type, but we'll just use 0 for now
        %!env{$name} = 0;
    }
}

method handle-procedure($proc) {
    for $proc<statements>.flat -> $stmt {
        self.handle-statement($stmt);
    }
}

method handle-statement($stmt) {
    given $stmt<type> {
        when 'assignment' {
            my $val = self.evaluate($stmt<value>);
            %!env{$stmt<name>} = $val;
        }
        when 'say' {
            my $val = self.evaluate($stmt<value>);
            say $val.defined ?? $val !! "(undef)";
        }
        when 'if' {
            #self.trace( "Handling IF statement" );
            #self.trace( "Condition: " ~ $stmt<condition>.perl );  # Debugging output

            my $condition = self.evaluate($stmt<condition>);
            #self.trace( "Condition evaluated to: " ~ $condition.perl);  # Debugging output

            if $condition {
                for $stmt<then>.flat -> $then_stmt {
                    self.handle-statement($then_stmt);
                }
            } 
            else {
                my $handled = False;
                #self.trace( "Condition was false, checking ELSIFs" );
                for ($stmt<elsif> // []).flat -> $elsif_clause {
                    if self.evaluate($elsif_clause<condition>) {
                        for $elsif_clause<then>.flat -> $elsif_stmt {
                            self.handle-statement($elsif_stmt);
                        }
                        $handled = True;
                        last;
                    }
                }
                if ($handled == False) && $stmt<else> {
                    #self.trace( "Handling ELSE statement" );
                    for $stmt<else><statements>.flat -> $else_stmt {
                        self.handle-statement($else_stmt);
                    }
                }
            }
        }
        when 'while' {
            #self.trace( "Handling WHILE statement" );
            while self.evaluate($stmt<condition>) {
                for $stmt<body>.flat -> $body_stmt {
                    self.handle-statement($body_stmt);
                }
            }
        }
        when 'repeat' {
            #self.trace( "Handling REPEAT statement" );
            repeat {
                for $stmt<body>.flat -> $body_stmt {
                    self.handle-statement($body_stmt);
                }
            } while !self.evaluate($stmt<condition>);
        }
        when 'for' {
            my $start = self.evaluate($stmt<start>);
            my $end   = self.evaluate($stmt<end>);
            my $step  = $stmt<step> ?? self.evaluate($stmt<step>) !! 1;

            #self.trace( "Handling FOR loop: " ~ $stmt<variable> ~ " from " ~ $start.perl ~ " to " ~ $end.perl ~ " by " ~ $step.perl );

            %!env{$stmt<variable>} = $start;
            if $step > 0 {
                while %!env{$stmt<variable>} <= $end {
                    for $stmt<body>.flat -> $body-stmt {
                        self.handle-statement($body-stmt);
                    }
                    %!env{$stmt<variable>} += $step;
                }
            }
            elsif $step < 0 {
                while %!env{$stmt<variable>} >= $end {
                    for $stmt<body>.flat -> $body-stmt {
                        self.handle-statement($body-stmt);
                    }
                    %!env{$stmt<variable>} += $step;
                }
            }
            else {
                die "Step value cannot be zero";
            }
        }
        default {
            die "Unknown statement type: {$stmt<type>}";
        }
    }
}

method evaluate($expr) {
    #self.trace( "Evaluating: " ~ $expr.perl  );  # Debugging output
    #self.trace( " - type is: " ~ $expr<type> );  # Debugging output

    # Handle different expression types
    given $expr<type> {
        when 'number'    { return $expr<value> }
        when 'string-literal'     { return $expr<value> }
        when 'identifier' {
            my $name = $expr<name>;
            return %!env{$name} // die "Undefined variable '$name'";
        }
        when 'compare' {
            my $lhs  = self.evaluate($expr<lhs>);
            my $rhs = self.evaluate($expr<rhs>);
            given $expr<op> {
                when '==' { return $lhs == $rhs }
                when '!=' { return $lhs != $rhs }
                when '<'  { return $lhs < $rhs }
                when '>'  { return $lhs > $rhs }
                when '<=' { return $lhs <= $rhs }
                when '>=' { return $lhs >= $rhs }
                default   { die "Unknown comparison operator: {$expr<op>}" }
            }
        }
        when 'binop' {
            my $lhs  = self.evaluate($expr<lhs>);
            my $rhs = self.evaluate($expr<rhs>);
            given $expr<op> {
                when '+'  { return $lhs + $rhs }
                when '-'  { return $lhs - $rhs }
                when '*'  { return $lhs * $rhs }
                when '/'  { return $rhs == 0 ?? die "Division by zero" !! $lhs / $rhs }
                when '%'  { return $rhs == 0 ?? die "Modulo by zero"   !! $lhs % $rhs }
                default   { die "Unknown operator: {$expr<op>}" }
            }
        }
        default {
            die "Unknown expression: " ~ dd $expr;
        }
    }
}
