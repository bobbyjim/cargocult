use Xenober16::AST::ASTNamedNode;
use Xenober16::AST::ParamDeclNode;
use Xenober16::AST::IdentifierNode;
use Xenober16::AST::PragmaNode;
#use Xenober16::AST::StatementNode;

class Xenober16::AST::ProcDeclNode does Xenober16::AST::ASTNode {

	#has Str $.name; in ASTNamedNode
	#has Int $.source-line; in ASTNode

	has Xenober16::AST::IdentifierNode $.name;
	has Xenober16::AST::ParamDeclNode @.params;
	has Str $.disambiguation-name is rw;
	has Str $.return-type;
	has Xenober16::AST::PragmaNode @.pragmas;
	has Mu @.body;


	method node-type() { "ProcDeclNode" }

	method disambiguation-name {
		$.disambiguation-name //= self.build-disambiguation-name;
	}

	method build-disambiguation-name() {
		# Build a disambiguation name based on the procedure name and parameters
		my $name = $.name.name;
		my $params-sig = @.params.map({ 
			if $_ ~~ Xenober16::AST::ParamDeclNode {
				$_.type
			} else {
				# Handle other types of parameters if needed
				say "⚠️  Unexpected param in build-disambiguation-name: {$_.^name}";
				'<unknown-param>'
			}
		}).join('_');
		
		my $ret = $.return-type // 'void';
		$.disambiguation-name = "{$name}-{$params-sig}->{$ret}";
		return $.disambiguation-name;
	}

	method dump($indent="") {
		say $indent ~ "ProcDeclNode:";
		say $indent ~ "  name: " ~ $.name;
		say $indent ~ "  disambiguation name: " ~ $.disambiguation-name if $.disambiguation-name;
		say $indent ~ "  return type: " ~ $.return-type if $.return-type;
		if @.params {
			say $indent ~ "  parameters:";
			for @.params -> $p { $p.dump($indent ~ "    ") }
		}
		
		if @.pragmas {
			say $indent ~ "  pragmas: " ~ @.pragmas».gist.join(", ");
		}

		if @.body {
			say $indent ~ "  body:";
			for @.body -> $stmt { $stmt.dump($indent ~ "    ") }
		}
			say $indent ~ self.line-info;
	}
}