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
use Xenober16::AST::ForNode;
use Xenober16::AST::CaseNode;
use Xenober16::AST::CallNode;
use Xenober16::AST::BinaryOpNode;
use Xenober16::AST::IdentifierNode;
use Xenober16::AST::NumberNode;
use Xenober16::AST::StringNode;
use Xenober16::AST::RangeNode;
use Xenober16::AST::ReturnNode;
use Xenober16::AST::EnumNode;
use Xenober16::AST::MemoryRefNode;
use Xenober16::AST::AreaAccessNode;

# Symbol tables
has %!variables;
has %!constants;
has %!procedures;
has %!memory-areas;
has %!ram;
has %!banks;

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
    
    # Process module parameters as constants
    if $node.identification.parameters {
        for $node.identification.parameters.flat -> $param {
            next unless $param ~~ Hash;
            my $value = self.eval-expr($param<default>);
            %!constants{$param<name>} = $value;
            say "[🎛️  Parameter: {$param<name>} = $value]";
        }
    }
    
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
    my $default-value = self!default-value($node.vtype);
    %!variables{$node.name} = {
        type  => $node.vtype,
        area  => $node.area,
        value => $default-value,
    };
    my $area-str = $node.area ?? " IN {$node.area}" !! "";
    say "[📊 Variable: {$node.name} : {$node.vtype}$area-str]";
}

multi method interpret(Xenober16::AST::EnumNode $node) {
    # Store enum members as constants
    my $next-value = 0;
    for @($node.members) -> $member {
        my $value = $member<value> // $next-value;
        %!constants{$member<name>} = $value;
        $next-value = $value + 1;
    }
    say "[📋 Enum: {$node.name} with {@($node.members).elems} members]";
}

multi method interpret(Xenober16::AST::ProcDeclNode $node) {
    %!procedures{$node.name} = $node;
    say "[⚙️  Procedure: {$node.name}]";
}

# ===== STATEMENTS =====

multi method interpret(Xenober16::AST::AssignmentNode $node) {
    if $node.target ~~ Xenober16::AST::MemoryRefNode {
        my $addr = self.eval-expr($node.target.address);
        my $bank = $node.target.bank.defined ?? self.eval-expr($node.target.bank) !! Nil;
        my $value = self.eval-expr($node.expression);
        if $bank.defined {
            %!banks{$bank} //= {};
            %!banks{$bank}{$addr} = $value;
        } else {
            %!ram{$addr} = $value;
        }
    } elsif $node.target ~~ Xenober16::AST::AreaAccessNode {
        my $area-name = $node.target.area-name;
        unless %!memory-areas{$area-name}:exists {
            die "Undefined memory area: $area-name";
        }
        my $area = %!memory-areas{$area-name};
        my $index = self.eval-expr($node.target.index);
        my $base-addr = $area.area-type eq 'RAM' ?? $area.address !! $area.bank-address;
        my $actual-addr = $base-addr + $index;
        my $value = self.eval-expr($node.expression);
        
        if $area.area-type eq 'BANK' {
            %!banks{$area.bank} //= {};
            %!banks{$area.bank}{$actual-addr} = $value;
        } else {
            %!ram{$actual-addr} = $value;
        }
    } elsif $node.target.^name eq 'Xenober16::AST::IdentifierNode' {
        my $target = $node.target.name;
        my $value = self.eval-expr($node.expression);
        
        # Check if it's a memory area
        if %!memory-areas{$target}:exists {
            if $node.target.indices.elems > 0 {
                my $index = self.eval-expr($node.target.indices[0]);
                my $area = %!memory-areas{$target};
                my $addr = $area.area-type eq 'RAM'
                    ?? $area.address + $index
                    !! $area.bank-address + $index;
                
                if $area.area-type eq 'RAM' {
                    %!ram{$addr} = $value;
                } else {
                    %!banks{$area.bank}{$addr} = $value;
                }
                return;
            }
            die "Memory area {$target} requires array indexing";
        }
        
        # Handle regular variables
        unless %!variables{$target}:exists {
            die "Undefined variable: $target";
        }
        
        # Handle array indexing
        if $node.target.indices.elems > 0 {
            my $index = self.eval-expr($node.target.indices[0]);
            my $arr = %!variables{$target}<value>;
            # Use splice to modify array element
            $arr.splice($index, 1, $value);
        } else {
            %!variables{$target}<value> = $value;
        }
    } else {
        die "Unknown assignment target type: {$node.target.^name}";
    }
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

multi method interpret(Xenober16::AST::ForNode $node) {
    my $start-val = self.eval-expr($node.start);
    my $end-val = self.eval-expr($node.end);
    my $step-val = $node.step ?? self.eval-expr($node.step) !! 1;
    
    # Extract numeric values (handle both Ints and NumberNode objects)
    my $start = $start-val ~~ Xenober16::AST::NumberNode ?? $start-val.value !! $start-val;
    my $end = $end-val ~~ Xenober16::AST::NumberNode ?? $end-val.value !! $end-val;
    my $step = $step-val ~~ Xenober16::AST::NumberNode ?? $step-val.value !! $step-val;
    
    if $step > 0 {
        # Ascending loop
        for $start .. $end -> $i {
            %!variables{$node.variable} = { value => $i };
            self.interpret($_) for @($node.body);
        }
    } else {
        # Descending loop
        for $start ... $end -> $i {
            %!variables{$node.variable} = { value => $i };
            self.interpret($_) for @($node.body);
        }
    }
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
    
    # Evaluate arguments while keeping original nodes for copy-out
    my @arg-nodes  = @($node.arguments);
    my @arg-values = @arg-nodes.map({ self.eval-expr($_) });
    
    # Save current variable scope
    my %saved-vars = %!variables.clone;
    
    # Bind parameters
    if $proc.parameters && $proc.parameters.elems > 0 {
        for @($proc.parameters) Z @arg-values -> ($param, $arg) {
            %!variables{$param.name} = {
                type  => $param.ptype,
                value => $arg,
            };
        }
    }
    
    my $return-value = Nil;
    
    # Execute procedure body
    try {
        self.interpret($_) for @($proc.body);
        CATCH {
            when ProcReturn {
                $return-value = .value;
            }
        }
    }
    
    # Copy-out parameter values for identifier arguments
    if $proc.parameters && $proc.parameters.elems > 0 {
        for @($proc.parameters) Z @arg-nodes -> ($param, $arg-node) {
            next unless $arg-node ~~ Xenober16::AST::IdentifierNode;
            if %!variables{$param.name}:exists {
                %saved-vars{$arg-node.name} //= { type => $param.ptype };
                %saved-vars{$arg-node.name}<value> = %!variables{$param.name}<value>;
            }
        }
    }
    
    # Restore variables to caller scope
    %!variables = %saved-vars;
    
    return $return-value;
}

multi method interpret(Xenober16::AST::ReturnNode $node) {
    my $value = $node.expr.defined ?? self.eval-expr($node.expr) !! Nil;
    ProcReturn.new(:value($value)).throw;
}

# ===== EXPRESSION EVALUATION =====

multi method eval-expr(Xenober16::AST::NumberNode $node) {
    return $node.value;
}

multi method eval-expr(Xenober16::AST::StringNode $node) {
    return $node.value;
}

multi method eval-expr(Xenober16::AST::RangeNode $node) {
    return $node;
}

multi method eval-expr(Xenober16::AST::IdentifierNode $node) {
    # Check constants first
    if %!constants{$node.name}:exists {
        return %!constants{$node.name};
    }
    
    # Check if it's a memory area
    if %!memory-areas{$node.name}:exists {
        if $node.indices.elems > 0 {
            my $index = self.eval-expr($node.indices[0]);
            my $area = %!memory-areas{$node.name};
            my $addr = $area.area-type eq 'RAM' 
                ?? $area.address + $index
                !! $area.bank-address + $index;
            
            if $area.area-type eq 'RAM' {
                return %!ram{$addr} // 0;
            } else {
                return %!banks{$area.bank}{$addr} // 0;
            }
        }
        die "Memory area {$node.name} requires array indexing";
    }
    
    # Then variables
    if %!variables{$node.name}:exists {
        my $value = %!variables{$node.name}<value>;
        
        # Handle array indexing
        if $node.indices.elems > 0 {
            my $index = self.eval-expr($node.indices[0]);
            return $value[$index];
        }
        
        return $value;
    }
    die "Undefined identifier: {$node.name}";
}

multi method eval-expr(Xenober16::AST::MemoryRefNode $node) {
    my $addr = self.eval-expr($node.address);
    my $bank = $node.bank.defined ?? self.eval-expr($node.bank) !! Nil;
    if $bank.defined {
        return %!banks{$bank}{$addr} // 0;
    }
    return %!ram{$addr} // 0;
}

multi method eval-expr(Xenober16::AST::AreaAccessNode $node) {
    my $area-name = $node.area-name;
    unless %!memory-areas{$area-name}:exists {
        die "Undefined memory area: $area-name";
    }
    my $area = %!memory-areas{$area-name};
    my $index = self.eval-expr($node.index);
    my $base-addr = $area.area-type eq 'RAM' ?? $area.address !! $area.bank-address;
    my $actual-addr = $base-addr + $index;
    
    if $area.area-type eq 'BANK' {
        return %!banks{$area.bank}{$actual-addr} // 0;
    } else {
        return %!ram{$actual-addr} // 0;
    }
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
    # Handle array types  
    if $type ~~ /^'array' \s* '[' \s* (\d+) \s* ']' \s* 'of' \s+ (.+)$/ {
        my $size = +$0;
        # Create mutable array with proper scalar containers
        my @arr;
        @arr[$_] = 0 for ^$size;
        return @arr;
    }
    
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
