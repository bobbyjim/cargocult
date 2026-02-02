use Xenober16::AST::ASTNode;
use Xenober16::AST::ID_DivisionNode;

class Xenober16::AST::ModuleNode does Xenober16::AST::ASTNode {
	has Xenober16::AST::ID_DivisionNode $.metadata;
	has @.vars;
	has @.statements;

	method Str() { 
		my $meta = $!metadata ?? $!metadata.Str !! "(no metadata)";
		"ModuleNode(metadata => $meta)"
	}

	method dump($indent="") {
		say $indent ~ "ModuleNode:";
		say $indent ~ "  metadata: ";
		$!metadata.dump($indent ~ "   ");
		if @!vars {
			say $indent ~ " vars: ";
			@!vars>>.dump($indent ~ "    ");
		}
		if @!statements {
			say $indent ~ " statements: ";
			@!statements>>.dump($indent ~ "    ");
		}
		say $indent ~ self.line-info;
	}
}