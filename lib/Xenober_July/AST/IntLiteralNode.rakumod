use Xenober16::AST::ASTNode;

class Xenober16::AST::IntLiteralNode does Xenober16::AST::ASTNode {
	has Int $.value;

	method Str() { "IntLiteralNode(value => $!value)" }

	method dump($indent="") {
		say $indent ~ "IntLiteralNode: $!value" ~ self.line-info;
	}
}
