use Xenober16::AST::ASTNode;

role Xenober16::AST::ASTNamedNode does Xenober16::AST::ASTNode {

	has Str $.name;

	method Str() { 
		"NamedNode(name => '" ~ $.name ~ "', type => " ~ self.node-type ~ ")"
	}

	method dump($indent="") {
		say $indent ~ "NamedNode:";
		say $indent ~ "  name: " ~ $.name;
		say $indent ~ self.line-info;
	}

}
