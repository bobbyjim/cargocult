unit class Xenober16::Interpreter;

use Xenober16::AST::ASTNode;
use Xenober16::AST::ProgramNode;
use Xenober16::AST::IdentificationNode;
use Xenober16::AST::ImportNode;
use Xenober16::AST::ConstDeclNode;
use Xenober16::AST::MemoryAreaNode;
use Xenober16::AST::VarDeclNode;
use Xenober16::AST::ParamDeclNode;
use Xenober16::AST::ProcDeclNode;
use Xenober16::AST::AssignmentNode;
use Xenober16::AST::SayNode;
use Xenober16::AST::EchoNode;
use Xenober16::AST::IfNode;
use Xenober16::AST::WhileNode;
use Xenober16::AST::RepeatNode;
use Xenober16::AST::CaseNode;
use Xenober16::AST::CallNode;
use Xenober16::AST::BinaryOpNode;
use Xenober16::AST::IdentifierNode;
use Xenober16::AST::NumberNode;
use Xenober16::AST::StringNode;
use Xenober16::AST::RangeNode;

# Symbol tables
has %!variables;
has %!constants;
has %!procedures;
has %!memory-areas;

# Exception for procedure return
class ProcReturn is Exception {
    has $.value;
}

# Main entry point
method run(Xenober16::AST::ProgramNode $ast) {
    say "[🔎 Starting interpretation]";
    
    # Process program
    self.interpret($ast);
    
    say "[✅ Program executed successfully]";
}

# ===== PROGRAM STRUCTURE =====

multi method interpret(Xenober16::AST::ProgramNode $node) {
    # Process identification
    say "[📋 Module: {$node.identification.module-id}]";
    say "[👤 Author: {$node.identification.author}]" if $node.identification.author;
    say "[📝 Description: {$node.identification.description}]" if $node.identification.description;
    
    # Process imports
    self.interpret($_) for @($node.imports);
    
    # Process constants
    self.interpret($_) for @($node.constants);
    
    # Process memory areas
    self.interpret($_) for @($node.memory);
    
    # Process data declarations
    self.interpret($_) for @($node.data);
    
    # Process procedures
    self.interpret($_) for @($node.procedures);
    
    # Execute main division
    self.interpret($_) for @($node.main);
}

# ===== DECLARATIONS =====

multi method interpret(Xenober16::AST::ImportNode $node) {
    say "[📦 Import: {$node.module}]";
    # TODO: Actual module loading
}

multi method interpret(Xenober16::AST::ConstDeclNode $node) {
    my $value = self.eval-expr($node.value);
    %!constants{$node.name} = $value;
    say "[🔒 Constant: {$node.name} = $value]";
}

multi method interpret(Xenober16::AST::MemoryAreaNode $node) {
    %!memory-areas{$node.name} = $node;
    my $loc = $node.area-type eq 'RAM' 
        ?? "RAM \${$node.address.base(16)}"
        !! "BANK {$node.bank} \${$node.bank-address.base(16)}";
    say "[🗂️  Memory area: {$node.name} at $loc, size {$node.size}]";
}

multi method interpret(Xenober16::AST::VarDeclNode $node) {
    %!variables{$node.name} = {
        type  => $node.vtype,
        area  => $node.area,
        value => self!default-value($node.vtype),
    };
    my $area-str = $node.area ?? " IN {$node.area}" !! "";
    say "[📊 Variable: {$node.name} : {$node.vtype}$area-str]";
}

multi method interpret(Xenober16::AST::ProcDeclNode $node) {
    %!procedures{$node.name} = $node;
    say "[⚙️  Procedure: {$node.name}]";
}

# ===== STATEMENTS =====

multi method interpret(Xenober16::AST::AssignmentNode $node) {
    my $target = $node.target.name;
    unless %!variables{$target}:exists {
        die "Undefined variable: $target";
    }
    my $value = self.eval-expr($node.expression);
    %!variables{$target}<value> = $value;
}

multi method interpret(Xenober16::AST::SayNode $node) {
    my $value = self.eval-expr($node.expression);
    say $value;
}

multi method interpret(Xenober16::AST::EchoNode $node) {
    my $value = self.eval-expr($node.expression);
    print $value;
}

multi method interpret(Xenober16::AST::IfNode $node) {
    my $condition = self.eval-expr($node.condition);
    
    if $condition {
        self.interpret($_) for @($node.then-branch);
    }
    elsif $node.elsif-branches {
        for @($node.elsif-branches) -> $elsif {
            my $elsif-cond = self.eval-expr($elsif<condition>);
            if $elsif-cond {
                self.interpret($_) for @($elsif<body>);
                return;
            }
        }
        # No elsif matched, try else
        if $node.else-branch {
            self.interpret($_) for @($node.else-branch);
        }
    }
    elsif $node.else-branch {
        self.interpret($_) for @($node.else-branch);
    }
}

multi method interpret(Xenober16::AST::WhileNode $node) {
    while self.eval-expr($node.condition) {
        self.interpret($_) for @($node.body);
    }
}

multi method interpret(Xenober16::AST::RepeatNode $node) {
    repeat {
        self.interpret($_) for @($node.body);
    } until self.eval-expr($node.condition);
}

multi method interpret(Xenober16::AST::CaseNode $node) {
    my $selector = self.eval-expr($node.selector);
    
    for @($node.branches) -> $branch {
        for @($branch<selectors>) -> $sel {
            if self!matches-selector($selector, $sel) {
                self.interpret($_) for @($branch<body>);
                return;
            }
        }
    }
    
    # No branch matched, try else
    if $node.else-branch {
        self.interpret($_) for @($node.else-branch);
    }
}

multi method interpret(Xenober16::AST::CallNode $node) {
    unless %!procedures{$node.name}:exists {
        die "Undefined procedure: {$node.name}";
    }
    
    my $proc = %!procedures{$node.name};
    
    # Evaluate arguments
    my @args = $node.arguments.map({ self.eval-expr($_) });
    
    # Save current variable scope
    my %saved-vars = %!variables.clone;
    
    # Bind parameters
    if $proc.parameters && $proc.parameters.elems > 0 {
        for @($proc.parameters) Z @args -> ($param, $arg) {
            %!variables{$param.name} = {
                type  => $param.ptype,
                value => $arg,
            };
        }
    }
    
    # Execute procedure body
    try {
        self.interpret($_) for @($proc.body);
        CATCH {
            when ProcReturn {
                %!variables = %saved-vars;
                return .value;
            }
        }
    }
    
    # Restore variables
    %!variables = %saved-vars;
}

# ===== EXPRESSION EVALUATION =====

multi method eval-expr(Xenober16::AST::NumberNode $node) {
    return $node.value;
}

multi method eval-expr(Xenober16::AST::StringNode $node) {
    return $node.value;
}

multi method eval-expr(Xenober16::AST::IdentifierNode $node) {
    # Check constants first
    if %!constants{$node.name}:exists {
        return %!constants{$node.name};
    }
    # Then variables
    if %!variables{$node.name}:exists {
        return %!variables{$node.name}<value>;
    }
    die "Undefined identifier: {$node.name}";
}

multi method eval-expr(Xenober16::AST::BinaryOpNode $node) {
    my $left = self.eval-expr($node.left);
    my $right = self.eval-expr($node.right);
    
    given $node.op {
        when '+' { return $left + $right }
        when '-' { return $left - $right }
        when '*' { return $left * $right }
        when '/' { return $left div $right }
        when 'MOD' { return $left % $right }
        when 'DIV' { return $left div $right }
        when '=' { return $left == $right ?? 1 !! 0 }
        when '<>' { return $left != $right ?? 1 !! 0 }
        when '<' { return $left < $right ?? 1 !! 0 }
        when '<=' { return $left <= $right ?? 1 !! 0 }
        when '>' { return $left > $right ?? 1 !! 0 }
        when '>=' { return $left >= $right ?? 1 !! 0 }
        when '&' { return $left ~ $right }
        default { die "Unknown operator: {$node.op}" }
    }
}

multi method eval-expr(Xenober16::AST::CallNode $node) {
    return self.interpret($node);
}

# ===== HELPER METHODS =====

method !default-value($type) {
    given $type {
        when 'uint8' | 'uint16' | 'int8' | 'int16' { 0 }
        when 'string' { '' }
        default { 0 }
    }
}

method !matches-selector($value, $selector) {
    given $selector {
        when Xenober16::AST::NumberNode {
            return $value == $selector.value;
        }
        when Xenober16::AST::StringNode {
            return $value eq $selector.value;
        }
        when Xenober16::AST::RangeNode {
            return $selector.start <= $value <= $selector.end;
        }
        when Xenober16::AST::IdentifierNode {
            my $sel-value = self.eval-expr($selector);
            return $value == $sel-value;
        }
        default {
            return False;
        }
    }
}
