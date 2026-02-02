use Xenober16::AST::ASTNode;

class Xenober16::AST::SayNode does Xenober16::AST::ASTNode {
	has $.expr;  # The expression to say

	method Str() { "SayNode(expression => '$.expr')" }

	method dump($indent="") {
		say $indent ~ "SayNode:" ~ self.line-info;
		say $indent ~ "  expression: ";
		$!expr ~~ Xenober16::AST::ASTNode ?? $!expr.dump($indent ~ "    ") !! say $indent ~ "    $!expr";
	}
}
