use Xenober16::AST::ASTNode;
use Xenober16::AST::IdentifierNode;

class Xenober16::AST::ParamDeclNode does Xenober16::AST::ASTNode {

	has Xenober16::AST::IdentifierNode $.name;
	has Str $.type;
	has Any $.default = Nil;  # Optional initialization expression

	method Str() { 
		"ParamDeclNode(name => '" ~ $.name.name ~ "', type => '" ~ $.type.trim ~ "', default => " ~
		($!default.defined ?? $!default.Str !! 'Nil') ~ ")"
	}

	method BUILD(:$!name, :$!type, :$!default) {
		unless $!name ~~ Xenober16::AST::IdentifierNode {
			die "❌ ParamDeclNode requires a valid IdentifierNode for .name (got: {$!name.perl})";
		}
		unless $!type.defined && $!type.trim.chars {
			die "❌ ParamDeclNode missing or empty .type";
		}
	}

	method dump($indent="") {
		say $indent ~ "ParamDeclNode:";
		say $indent ~ "  name: " ~ $.name.name;
		say $indent ~ "  type: " ~ $.type;
		if $!default.defined {
			say $indent ~ "  default:";
			$!default ~~ Xenober16::AST::ASTNode ?? $!default.dump($indent ~ "    ") !! say $indent ~ "    $!default";
		} else {
			say $indent ~ "  default: (none)";
		}
		say $indent ~ self.line-info;
	}
}
