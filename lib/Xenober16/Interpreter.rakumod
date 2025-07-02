unit class Xenober16::Interpreter;

use Xenober16::AST::ASTNode;
use Xenober16::AST::ConstDeclNode;
use Xenober16::AST::ParamDeclNode;
use Xenober16::AST::VarDeclNode;    
use Xenober16::AST::IdentifierNode;
use Xenober16::AST::IntLiteralNode;
use Xenober16::AST::ModuleNode;
use Xenober16::AST::SayNode;   

use Xenober16::Builder::NodeFactory;

has %!symbols;

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

#    for $node.constants -> $const {
#        self.interpret($const);
#    }
    for $node.vars -> $decl {
        self.interpret($decl);
    }
    for $node.statements -> $stmt {
        self.interpret($stmt);
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

multi method interpret(Xenober16::AST::ConstDeclNode $node) {
    say "Interpreting constant declaration: " ~ $node.name.name ~ " = " ~ $node.value;

    my $value = self.interpret($node.value);
    say "  Constant value: $value";

    # Store the constant in the symbol table
    %!symbols{$node.name.name} = { 
        kind => 'constant',
        type => 'constant',
#        type => $node.type // inferred_type($value),
        value => $value,
    };
    return Nil;
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

multi method interpret(Any $node) {
    die "Unhandled AST node: " ~ $node.WHAT ~ " at line " ~ ($node.^can('source-line') ?? $node.source-line !! '?');
}
