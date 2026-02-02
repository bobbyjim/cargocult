unit class Xenober16::Interpreter;

use Xenober16::AST::ASTNode;
use Xenober16::AST::ParamDeclNode;
use Xenober16::AST::VarDeclNode;    
use Xenober16::AST::IdentifierNode;
use Xenober16::AST::IntLiteralNode;
use Xenober16::AST::ModuleNode;
use Xenober16::AST::SayNode;   
use Xenober16::AST::ProcDeclNode;
use Xenober16::AST::PragmaNode;
use Xenober16::AST::ReturnNode;
use Xenober16::AST::CallNode;

use Xenober16::Builder::NodeFactory;

has %!symbols;
has %!procs;

class ProcReturn is Exception {
    has $.value;

    method message {
        "Procedure returned with value: " ~ $.value;
    }
}

method run($ast) {
    say "[🔎 Starting interpretation]";
    self.interpret($ast);
    say "[✅ Program executed successfully]";
}

multi method interpret(Int $value) { $value }
multi method interpret(Str $value) { $value }
multi method interpret(Nil) { Nil }

multi method interpret(Xenober16::AST::ModuleNode $node) {
	say "Interpreting ModuleNode: "~ $node.metadata.perl;

    for $node.vars -> $decl {
        self.interpret($decl);
    }
    for $node.statements -> $stmt {
        if $stmt ~~ Xenober16::AST::ProcDeclNode {
            my $sig = $stmt.disambiguation-name;
            say "🔧 Registering procedure: $sig";
            %!procs{$sig} = $stmt;
        }
        else {
            self.interpret($stmt);
        }
    }

    my $meta = $node.metadata;
    say "Metadata type: ", $meta.WHAT.perl;
    say "Metadata instance? ", $meta.^name;

    my $name = $meta && $meta.module-id ?? $meta.module-id.name !! '<unknown>';
    %!symbols{$name} = 'module placeholder value';
    return Nil; 
}

multi method interpret(Xenober16::AST::IdentifierNode $node) {
    say "Interpreting IdentifierNode: " ~ $node.name;

    if %!symbols{$node.name}:exists {
        return %!symbols{$node.name}<value>;  # return the stored value for this identifier
    }
    else {
        die "Undefined identifier: {$node.name}";
    }
}

multi method interpret(Xenober16::AST::IntLiteralNode $node) {
    say "Interpreting IntLiteralNode: " ~ $node.value;
    return $node.value;
}

multi method interpret(Xenober16::AST::VarDeclNode $node) {
    say "Interpreting variable " ~ $node.name.name ~ " of type " ~ $node.type;

    my $value = Nil;
    if $node.init.defined {
        $value = self.interpret($node.init);
        say "  Initial value: $value";
    }

    # Store the variable in the symbol table
    %!symbols{$node.name.name} = { 
        type => $node.type, 
        value => $value,
    };
    return Nil;
}

multi method interpret(Xenober16::AST::SayNode $node) {
    say "Interpreting Say statement";
    my $result = self.interpret($node.expr);
    say "Output: $result";
    return Nil;
}

multi method interpret(Xenober16::AST::ProcDeclNode $node) {
    say "Interpreting ProcDeclNode: " ~ $node.name;

    my $sig = $node.disambiguation-name;

    # Store the procedure in the symbol table
    %!procs{$sig} = $node;
    say "🔧 Registered procedure: $sig";

    return Nil;
}

multi method interpet(Xenober16::AST::ReturnNode $node) {
    say "Interpreting Return node";
    my $value = $node.expr ?? self.interpret($node.expr) !! Nil;
    say "Returning value: $value";
    die ProcReturn.new(value => $value);
}

multi method interpret(Xenober16::AST::CallNode $node) {
    say "Interpreting Call to: " ~ $node.target.name;

    my $proc-name = $node.target.name;
    my $sig = $proc-name;  # For now, use the name as the signature

    my $proc = %!procs{$sig} or die "Undefined procedure: {$proc-name}";

    my @arg-values = $node.args.map({ self.interpret($_) });
    my %old-symbols = %!symbols.clone;

    # Assign params to local scope
    for @($proc.params) Z @arg-values -> ($param, $value) {
        say "  Assigning parameter " ~ $param.name ~ " = " ~ $value;
        %!symbols{$param.name} = { 
            type => $param.type, 
            value => $value,
        };
    }

    # Execute the procedure body
    my $return-value = Nil;

    try {
        for $proc.body -> $stmt {
            self.interpret($stmt);
        }
    }
    CATCH {
        default {
            if $_ ~~ ProcReturn {
                $return-value = $_.value;
            }
            else {
                die $_;
            }
        }
    }
    %!symbols = %old-symbols;  # Restore old symbols
    return $return-value;
}

multi method interpret(Any $node) {
    say("Interpreter can't digest this: $node");
    die "Unhandled AST node: " ~ $node.WHAT ~ " at line " ~ ($node.^can('source-line') ?? $node.source-line !! '?');
}
