use Xenober16::AST::ASTNode;

unit class Xenober16::AST::ParamDeclNode does ASTNode;

use Xenober16::AST::IdentifierNode;

	has Xenober16::AST::IdentifierNode $.name;
	has Str $.type;
	has Any $.default = Nil;  # Optional initialization expression

	method Str() { 
		"ParamDeclNode(name => '" ~ $.name.name ~ "', type => '" ~ $.type.trim ~ "', default => " ~
		($!default.defined ?? $!default.Str !! 'Nil') ~ ")"
	}

	method dump($indent="") {
		say $indent ~ "ParamDeclNode:";
		say $indent ~ "  name: " ~ $.name.name;
		say $indent ~ "  type: " ~ $.type;
		if $!default.defined {
			say $indent ~ "  default:";
			$!default ~~ ASTNode ?? $!default.dump($indent ~ "    ") !! say $indent ~ "    $!default";
		} else {
			say $indent ~ "  default: (none)";
		}
		say $indent ~ self.line-info;
	}

