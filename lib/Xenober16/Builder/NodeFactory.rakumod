unit class Xenober16::Builder::NodeFactory;

use Xenober16::AST::ASTNode;
use Xenober16::AST::IdentifierNode;
use Xenober16::Builder::DeclarationNodeFactory;

#has $.expr-factory = ExpressionNodeFactory.new;
has $.decl-factory = Xenober16::Builder::DeclarationNodeFactory.new;
#has $.stmt-factory = StatementNodeFactory.new;
#has $.module-factory = ModuleNodeFactory.new;

class ID_DivisionNode does ASTNode {
	has Xenober16::AST::IdentifierNode $.module-id;
	has @.parameters;
	has $.author = Nil;
	has $.date = Nil;
	has $.description = Nil;
	has $.license = Nil; 

	method Str() {
		my $id = $!module-id ?? $!module-id.Str !! "(no module-id)";
		"ID_DivisionNode(module-id => $id)"
	}

    method dump($indent = "") {
        say $indent ~ "ID_DivisionNode:";
        say $indent ~ "  module-id: ";
        $!module-id.dump($indent ~ "    ");
		if @!parameters {
			say $indent ~ "  parameters:";
			@!parameters>>.dump($indent ~ "    ");
		} else {
			say $indent ~ "  parameters: (none)";
		}
        say $indent ~ "  author: " ~ ($!author // '(none)');
        say $indent ~ "  date: " ~ ($!date // '(none)');
        say $indent ~ "  description: " ~ ($!description // '(none)');
		say $indent ~ "  license: " ~ ($!license // '(none)');
        say $indent ~ self.line-info;
	}
}

class IntLiteralNode does ASTNode {
	has Int $.value;

	method Str() { "IntLiteralNode(value => $!value)" }

	method dump($indent="") {
		say $indent ~ "IntLiteralNode: $!value" ~ self.line-info;
	}
}

class ModuleNode does ASTNode {
	has ID_DivisionNode $.metadata;
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

class SayNode does ASTNode {
	has $.expr;  # The expression to say

	method Str() { "SayNode(expression => '$.expr')" }

	method dump($indent="") {
		say $indent ~ "SayNode:" ~ self.line-info;
		say $indent ~ "  expression: ";
		$!expr ~~ ASTNode ?? $!expr.dump($indent ~ "    ") !! say $indent ~ "    $!expr";
	}
}

method build(Str $type, :$src = -1, *%args) {
	# Factory method to create nodes based on type
	given $type {
		when 'ID_DivisionNode'  { ID_DivisionNode.new(|%args, :source-line($src));  }
		when 'IntLiteralNode' 	{ IntLiteralNode.new(|%args, :source-line($src)) }
		# | 'BinaryOpNode'      
		# { $.expr-factory.build($type, |%args, :source-line($src)); }

		when 'ModuleNode' 		{ ModuleNode.new(|%args, :source-line($src)); 		}
		when 'IdentifierNode' 	{ Xenober16::AST::IdentifierNode.new(|%args, :source-line($src));  	}
		# { $.module-factory.build($type, |%args, :source-line($src)); }

		when 'SayNode'			{ SayNode.new(|%args, :source-line($src)); 			}
		# 'AssignNode' | 'IfNode' 
		# { $.stmt-factory.build($type, |%args, :source-line($src)); }

		when 'VarDeclNode' | 'ParamDeclNode' | 'ConstDeclNode' { 
			# Handle VarDeclNode, ParamDeclNode, ConstDeclNode
			# These nodes are defined in DeclarationNodeFactory.rakumod
			# so we assume they are imported or available in the same context
			$.decl-factory.build($type, |%args, :source-line($src));
		}

		default 				{ die "Unknown node type: $type"; 		}
	}
}
