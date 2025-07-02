use Xenober16::AST::ASTNode;
use Xenober16::AST::IdentifierNode;

class Xenober16::AST::ConstDeclNode does Xenober16::AST::ASTNode {

	has Xenober16::AST::IdentifierNode $.name;  
	has Any $.value;  # Constant value, must be defined

	method Str() { 
		"ConstDeclNode(name => '" ~ $.name.name ~ "', value => " ~
		($!value.defined ?? $!value.Str !! 'Nil') ~ ")"
	}

	method dump($indent="") {
		say $indent ~ "ConstDeclNode:";
		say $indent ~ "  name: " ~ $.name.name;
		if $!value.defined {
			say $indent ~ "  value:";
			$!value ~~ Xenober16::AST::ASTNode ?? $!value.dump($indent ~ "    ") !! say $indent ~ "    $!value";
		} else {
			say $indent ~ "  value: (none)";
		}
		say $indent ~ self.line-info;
	}
}