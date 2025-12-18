use Xenober16::AST::ASTNamedNode;
use Xenober16::AST::IdentifierNode;

class Xenober16::AST::CallNode does Xenober16::AST::ASTNamedNode {

	has Xenober16::AST::IdentifierNode $.target;
	has @.args;

	method node-type() { 'CallNode' }

	method dump($indent = "") {
		say $indent ~ "CallNode:";
		say $indent ~ "  target: ", $.target.name;
		if @.args {
			say $indent ~ "  args:";
			for @.args -> $arg {
				$arg.dump($indent ~ "    ");
			}
		}
		say $indent ~ self.line-info;
	}
}
