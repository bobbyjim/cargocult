use Xenober16::AST::ASTNode;

class Xenober16::AST::ReturnNode does Xenober16::AST::ASTNode {

	has $.expr;

	method node-type() { 'ReturnNode' }

	method dump($indent="") {
		say $indent ~ "ReturnNode:";
		say $indent ~ "  expr:";
		$.expr.dump($indent ~ "    ") if $.expr;
		say $indent ~ "  " ~ self.line-info;
	}

}
