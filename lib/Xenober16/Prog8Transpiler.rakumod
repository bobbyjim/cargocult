unit class Xenober16::Prog8Transpiler;

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

has Str $.indent = "    ";
has Int $!indent-level = 0;
has %!memory-areas;

# Main entry point
method transpile(Xenober16::AST::ProgramNode $ast) returns Str {
    my @output;
    
    @output.push: self!emit-header($ast);
    @output.push: "";
    @output.push: self!emit-imports($ast.imports);
    @output.push: "";
    @output.push: self!emit-constants($ast.constants, $ast.identification);
    @output.push: "";
    @output.push: self!emit-memory-areas($ast.memory);
    @output.push: "";
    @output.push: self!emit-data($ast.data);
    @output.push: "";
    @output.push: self!emit-procedures($ast.procedures);
    @output.push: "";
    @output.push: self!emit-main($ast.main);
    
    return @output.grep(*.defined).join("\n\n").trim;
}

# ===== HEADER & MODULE INFO =====

method !emit-header(Xenober16::AST::ProgramNode $ast) returns Str {
    my @lines;
    
    my $id = $ast.identification;
    @lines.push: "; Transpiled from Xenober16 to Prog8";
    @lines.push: "; Module: {$id.module-id}" if $id.module-id;
    @lines.push: "; Author: {$id.author}" if $id.author;
    @lines.push: "; Description: {$id.description}" if $id.description;
    @lines.push: "";
    
    # Use lowercase module name for prog8
    my $module-name = $id.module-id.lc;
    @lines.push: "$module-name \{";
    
    return @lines.join("\n");
}

# ===== IMPORTS =====

method !emit-imports(@imports) returns Str {
    return "" unless @imports;
    
    my @lines;
    for @imports -> $import {
        next unless $import ~~ Xenober16::AST::ImportNode;
        my $module = $import.module.lc;
        @lines.push: self!indent("import $module");
    }
    
    return @lines ?? @lines.join("\n") !! "";
}

# ===== CONSTANTS =====

method !emit-constants(@constants, $identification) returns Str {
    my @lines;
    
    # Module parameters become constants
    if $identification.parameters {
        for $identification.parameters.flat -> $param {
            next unless $param ~~ Hash;
            if $param<default> {
                my $value = self.emit-expr($param<default>);
                my $type = self!map-type($param<type>);
                @lines.push: self!indent("const $type {$param<name>} = $value");
            }
        }
    }
    
    # Regular constants
    for @constants -> $const {
        next unless $const ~~ Xenober16::AST::ConstDeclNode;
        my $value = self.emit-expr($const.value);
        @lines.push: self!indent("const {$const.name} = $value");
    }
    
    return @lines ?? @lines.join("\n") !! "";
}

# ===== MEMORY AREAS =====

method !emit-memory-areas(@memory) returns Str {
    return "" unless @memory;
    
    my @lines;
    
    for @memory -> $area {
        next unless $area ~~ Xenober16::AST::MemoryAreaNode;
        %!memory-areas{$area.name} = $area;
        
        if $area.area-type eq 'RAM' {
            my $addr = '$' ~ $area.address.base(16).uc;
            @lines.push: self!indent("&uword {$area.name} = $addr  ; size: {$area.size}");
        } elsif $area.area-type eq 'BANK' {
            my $addr = '$' ~ $area.bank-address.base(16).uc;
            @lines.push: self!indent("; Memory area {$area.name} in BANK {$area.bank} at $addr (size: {$area.size})");
            @lines.push: self!indent("&uword {$area.name} = $addr  ; bank: {$area.bank}");
        }
    }
    
    return @lines ?? @lines.join("\n") !! "";
}

# ===== DATA DIVISION =====

method !emit-data(@data) returns Str {
    return "" unless @data;
    
    my @lines;
    
    for @data -> $decl {
        when Xenober16::AST::VarDeclNode {
            my $type = self!map-type($decl.vtype);
            my $area-comment = $decl.area ?? "  ; in area {$decl.area}" !! "";
            @lines.push: self!indent("$type {$decl.name}$area-comment");
        }
        when Xenober16::AST::EnumNode {
            # Emit enum members as constants
            my $next-value = 0;
            for @($decl.members) -> $member {
                my $value = $member<value> // $next-value;
                @lines.push: self!indent("const ubyte {$member<name>} = $value");
                $next-value = $value + 1;
            }
        }
    }
    
    return @lines ?? @lines.join("\n") !! "";
}

# ===== PROCEDURES =====

method !emit-procedures(@procedures) returns Str {
    return "" unless @procedures;
    
    my @lines;
    
    for @procedures -> $proc {
        next unless $proc ~~ Xenober16::AST::ProcDeclNode;
        @lines.push: self!emit-procedure($proc);
    }
    
    return @lines.join("\n\n");
}

method !emit-procedure(Xenober16::AST::ProcDeclNode $proc) returns Str {
    my @lines;
    
    # Build parameter list
    my @params;
    if $proc.parameters {
        for @($proc.parameters) -> $param {
            my $type = self!map-type($param.ptype);
            @params.push: "$type {$param.name}";
        }
    }
    
    my $params-str = @params ?? ' ' ~ @params.join(', ') !! '';
    @lines.push: self!indent("sub {$proc.name}($params-str) \{");
    
    $!indent-level++;
    for @($proc.body) -> $stmt {
        my $emitted = self.emit-statement($stmt);
        @lines.push: $emitted if $emitted;
    }
    $!indent-level--;
    
    @lines.push: self!indent("}");
    
    return @lines.join("\n");
}

# ===== MAIN DIVISION =====

method !emit-main(@main) returns Str {
    return "" unless @main;
    
    my @lines;
    @lines.push: self!indent("sub start() \{");
    
    $!indent-level++;
    for @main -> $stmt {
        my $emitted = self.emit-statement($stmt);
        @lines.push: $emitted if $emitted;
    }
    $!indent-level--;
    
    @lines.push: self!indent("}");
    @lines.push: "}";  # Close module
    
    return @lines.join("\n");
}

# ===== STATEMENTS =====

multi method emit-statement(Xenober16::AST::AssignmentNode $node) returns Str {
    my $target = self.emit-lvalue($node.target);
    my $expr = self.emit-expr($node.expression);
    return self!indent("$target = $expr");
}

multi method emit-statement(Xenober16::AST::SayNode $node) returns Str {
    my $expr = self.emit-expr($node.expression);
    return self!indent("txt.print($expr)") ~ "\n" ~ self!indent("txt.nl()");
}

multi method emit-statement(Xenober16::AST::EchoNode $node) returns Str {
    my $expr = self.emit-expr($node.expression);
    return self!indent("txt.print($expr)");
}

multi method emit-statement(Xenober16::AST::IfNode $node) returns Str {
    my @lines;
    
    my $cond = self.emit-expr($node.condition);
    @lines.push: self!indent("if $cond \{");
    
    $!indent-level++;
    for @($node.then-branch) -> $stmt {
        @lines.push: self.emit-statement($stmt);
    }
    $!indent-level--;
    
    # Handle elsif branches
    if $node.elsif-branches {
        for @($node.elsif-branches) -> $elsif {
            my $elsif-cond = self.emit-expr($elsif<condition>);
            @lines.push: self!indent("} else if $elsif-cond \{");
            $!indent-level++;
            for @($elsif<body>) -> $stmt {
                @lines.push: self.emit-statement($stmt);
            }
            $!indent-level--;
        }
    }
    
    # Handle else branch
    if $node.else-branch {
        @lines.push: self!indent("} else \{");
        $!indent-level++;
        for @($node.else-branch) -> $stmt {
            @lines.push: self.emit-statement($stmt);
        }
        $!indent-level--;
    }
    
    @lines.push: self!indent("}");
    
    return @lines.join("\n");
}

multi method emit-statement(Xenober16::AST::WhileNode $node) returns Str {
    my @lines;
    
    my $cond = self.emit-expr($node.condition);
    @lines.push: self!indent("while $cond \{");
    
    $!indent-level++;
    for @($node.body) -> $stmt {
        @lines.push: self.emit-statement($stmt);
    }
    $!indent-level--;
    
    @lines.push: self!indent("}");
    
    return @lines.join("\n");
}

multi method emit-statement(Xenober16::AST::RepeatNode $node) returns Str {
    my @lines;
    
    @lines.push: self!indent("repeat \{");
    
    $!indent-level++;
    for @($node.body) -> $stmt {
        @lines.push: self.emit-statement($stmt);
    }
    $!indent-level--;
    
    my $cond = self.emit-expr($node.condition);
    @lines.push: self!indent("} until $cond");
    
    return @lines.join("\n");
}

multi method emit-statement(Xenober16::AST::ForNode $node) returns Str {
    my @lines;
    
    my $start = self.emit-expr($node.start);
    my $end = self.emit-expr($node.end);
    my $step = $node.step ?? self.emit-expr($node.step) !! '1';
    
    # Prog8 for loop syntax: for var in start to end
    if $step eq '1' {
        @lines.push: self!indent("for {$node.variable} in $start to $end \{");
    } else {
        @lines.push: self!indent("for {$node.variable} in $start to $end step $step \{");
    }
    
    $!indent-level++;
    for @($node.body) -> $stmt {
        @lines.push: self.emit-statement($stmt);
    }
    $!indent-level--;
    
    @lines.push: self!indent("}");
    
    return @lines.join("\n");
}

multi method emit-statement(Xenober16::AST::CaseNode $node) returns Str {
    my @lines;
    
    my $selector = self.emit-expr($node.selector);
    @lines.push: self!indent("when $selector \{");
    
    $!indent-level++;
    for @($node.branches) -> $branch {
        my @selectors = @($branch<selectors>).map({ self.emit-expr($_) });
        for @selectors -> $sel {
            @lines.push: self!indent("$sel -> \{");
            $!indent-level++;
            for @($branch<body>) -> $stmt {
                @lines.push: self.emit-statement($stmt);
            }
            $!indent-level--;
            @lines.push: self!indent("}");
        }
    }
    
    # Handle else branch
    if $node.else-branch {
        @lines.push: self!indent("else -> \{");
        $!indent-level++;
        for @($node.else-branch) -> $stmt {
            @lines.push: self.emit-statement($stmt);
        }
        $!indent-level--;
        @lines.push: self!indent("}");
    }
    
    $!indent-level--;
    @lines.push: self!indent("}");
    
    return @lines.join("\n");
}

multi method emit-statement(Xenober16::AST::CallNode $node) returns Str {
    my @args = @($node.arguments).map({ self.emit-expr($_) });
    my $args-str = @args.join(', ');
    return self!indent("{$node.name}($args-str)");
}

multi method emit-statement(Xenober16::AST::ReturnNode $node) returns Str {
    if $node.expr {
        my $expr = self.emit-expr($node.expr);
        return self!indent("return $expr");
    } else {
        return self!indent("return");
    }
}

multi method emit-statement($node) returns Str {
    warn "Unhandled statement type: {$node.^name}";
    return self!indent("; TODO: {$node.^name}");
}

# ===== EXPRESSIONS =====

multi method emit-expr(Xenober16::AST::NumberNode $node) returns Str {
    return ~$node.value;
}

multi method emit-expr(Xenober16::AST::StringNode $node) returns Str {
    return '"' ~ $node.value ~ '"';
}

multi method emit-expr(Xenober16::AST::IdentifierNode $node) returns Str {
    return $node.name;
}

multi method emit-expr(Xenober16::AST::BinaryOpNode $node) returns Str {
    my $left = self.emit-expr($node.left);
    my $right = self.emit-expr($node.right);
    my $op = self!map-operator($node.op);
    
    return "($left $op $right)";
}

multi method emit-expr(Xenober16::AST::MemoryRefNode $node) returns Str {
    my $addr = self.emit-expr($node.address);
    if $node.bank {
        my $bank = self.emit-expr($node.bank);
        return '@(' ~ $bank ~ ':' ~ $addr ~ ')';
    } else {
        return '@(' ~ $addr ~ ')';
    }
}

multi method emit-expr(Xenober16::AST::AreaAccessNode $node) returns Str {
    my $index = self.emit-expr($node.index);
    return "{$node.area-name}[$index]";
}

multi method emit-expr(Xenober16::AST::CallNode $node) returns Str {
    my @args = @($node.arguments).map({ self.emit-expr($_) });
    my $args-str = @args.join(', ');
    return "{$node.name}($args-str)";
}

multi method emit-expr(Xenober16::AST::RangeNode $node) returns Str {
    return "{$node.start}..{$node.end}";
}

multi method emit-expr(Int $value) returns Str {
    return ~$value;
}

multi method emit-expr(Str $value) returns Str {
    return qq["$value"];
}

multi method emit-expr($node) returns Str {
    warn "Unhandled expression type: {$node.^name}";
    return "/* TODO: {$node.^name} */";
}

# ===== LVALUE EMISSION =====

multi method emit-lvalue(Xenober16::AST::IdentifierNode $node) returns Str {
    return $node.name;
}

multi method emit-lvalue(Xenober16::AST::MemoryRefNode $node) returns Str {
    my $addr = self.emit-expr($node.address);
    if $node.bank {
        my $bank = self.emit-expr($node.bank);
        return '@(' ~ $bank ~ ':' ~ $addr ~ ')';
    } else {
        return '@(' ~ $addr ~ ')';
    }
}

multi method emit-lvalue(Xenober16::AST::AreaAccessNode $node) returns Str {
    my $index = self.emit-expr($node.index);
    return "{$node.area-name}[$index]";
}

# ===== HELPER METHODS =====

method !indent(Str $text) returns Str {
    return ($.indent x $!indent-level) ~ $text;
}

method !map-type(Str $xenober-type) returns Str {
    given $xenober-type.lc {
        when 'uint8' | 'byte' { 'ubyte' }
        when 'uint16' | 'word' { 'uword' }
        when 'int8' { 'byte' }
        when 'int16' { 'word' }
        when 'char' { 'ubyte' }
        when 'string' { 'str' }
        default { $xenober-type }
    }
}

method !map-operator(Str $op) returns Str {
    given $op {
        when '=' { '==' }
        when '<>' { '!=' }
        when 'MOD' { '%' }
        when 'DIV' { '/' }
        when '&' { '+' }  # String concatenation becomes addition in prog8
        default { $op }
    }
}
