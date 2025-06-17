unit class Xenober16::Interpreter;

use Xenober16::Builder::NodeFactory;

has %!symbols;

method run($ast) {
	self.interpret($ast);
}

multi method interpret(Xenober16::Builder::NodeFactory::ASTNode $node) {
	die "Unhandled AST node: {$node.^name}";
}

multi method interpret(Xenober16::Builder::NodeFactory::ModuleNode $node) {
	say "Interpreting ModuleNode: " ~ $node.id.name;
	# Here you would add logic to handle the module, such as loading it or executing its contents.
    %!symbols{$node.id.name} = 'module placeholder value';
    return Nil;  # no real "value" to return for a module declaration yet
}

multi method interpret(Xenober16::Builder::NodeFactory::IdentifierNode $node) {
    say "Interpreting IdentifierNode: " ~ $node.name;
    if %!symbols{$node.name}:exists {
        return %!symbols{$node.name};  # return the stored value for this identifier
    }
    else {
        die "Undefined identifier: {$node.name}";
    }
}
