unit class Xenober16::Interpreter;

has %!env;  # Symbol table for variables

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
    say "Program Name: ", $id<name>;
}

method handle-data($data) {
    for $data<storage>.flat -> $decl {
        my $name = $decl<identifier>;
        my $type = $decl<data_type>;
		#say " - Declaring variable: $name of type $type";
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
            say self.evaluate($stmt<value>);
        }
        default {
            die "Unknown statement type: {$stmt<type>}";
        }
    }
}

method evaluate($expr) {
    given $expr<type> {
        when 'literal'    { return $expr<value> }
        when 'string'     { return $expr<value> }
        when 'identifier' {
            my $name = $expr<name>;
            return %!env{$name} // die "Undefined variable '$name'";
        }
        when 'binop' {
            my $lhs  = self.evaluate($expr<lhs>);
            my $rhs = self.evaluate($expr<rhs>);
            given $expr<op> {
                when '+' { return $lhs + $rhs }
                when '-' { return $lhs - $rhs }
                when '*' { return $lhs * $rhs }
                when '/' { return $rhs == 0 ?? die "Division by zero" !! $lhs / $rhs }
                when '%' { return $lhs % $rhs }
                default  { die "Unknown operator: {$expr<op>}" }
            }
        }
        when 'group' {
            return self.evaluate($expr<inner>);
        }
        default {
            die "Unknown expression: " ~ dd $expr;
        }
    }
}
