unit class Xenober16::Interpreter;

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

multi method interpret(Xenober16::Builder::NodeFactory::ModuleNode $node) {
	say "Interpreting ModuleNode: "~ $node.metadata.perl;

    for $node.vars -> $decl {
        say "Var: " ~ $decl;
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

multi method interpret(Xenober16::Builder::NodeFactory::IdentifierNode $node) {
    say "Interpreting IdentifierNode: " ~ $node.name;

    if %!symbols{$node.name}:exists {
        return %!symbols{$node.name}<value>;  # return the stored value for this identifier
    }
    else {
        die "Undefined identifier: {$node.name}";
    }
}

multi method interpret(Xenober16::Builder::NodeFactory::IntLiteralNode $node) {
    say "Interpreting IntLiteralNode: " ~ $node.value;
    return $node.value;
}

multi method interpret(Xenober16::Builder::NodeFactory::VarDeclNode $node) {
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

multi method interpret(Xenober16::Builder::NodeFactory::SayNode $node) {
    say "Interpreting Say statement";
    my $result = self.interpret($node.expr);
    say "Output: $result";
    return Nil;
}

multi method interpret(Xenober16::Builder::NodeFactory::ASTNode $node) {
    die "Unhandled AST node: " ~ $node.WHAT ~ " at line " ~ ($node.^can('source-line') ?? $node.source-line !! '?');
}
