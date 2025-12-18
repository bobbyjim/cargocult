use Xenober16::AST::ASTNamedNode;

class Xenober16::AST::PragmaNode does Xenober16::AST::ASTNamedNode {
	has Mu $.arg; # pragma value, can be any type (e.g. Bool, Str, Int, etc.)
	
	method node-type() { "PragmaNode" }

	method dump($indent="") {
		say $indent ~ "PragmaNode:";
		say $indent ~ "  name: " ~ $.name;
		say $indent ~ "  arg: " ~ $.arg if $.arg;
		say $indent ~ self.line-info;
	}
}
