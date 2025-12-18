use Xenober16::AST::ASTNode;
use Xenober16::AST::IdentifierNode;

class Xenober16::AST::VarDeclNode does Xenober16::AST::ASTNode {

	has Xenober16::AST::IdentifierNode $.name;
	has Str $.type;
	has Any $.init = Nil;  # Optional initialization expression

	method Str() { "VarDeclNode(name => '$.name', type => '$.type', init => '$.init')" }

	method dump($indent="") {
		say $indent ~ "VarDeclNode:";
		say $indent ~ "  name: " ~ $.name.name;
		say $indent ~ "  type: " ~ $.type;
		say $indent ~ "  init: " ~ ($!init // 'Nil');
		say $indent ~ self.line-info;
	}
}