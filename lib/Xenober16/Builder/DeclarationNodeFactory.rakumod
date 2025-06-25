unit class Xenober16::Builder::DeclarationNodeFactory;

use Xenober16::AST::ASTNode;
use Xenober16::AST::ConstDeclNode;
use Xenober16::AST::ParamDeclNode;
use Xenober16::AST::VarDeclNode;

method build(Str $type, :$src = -1, *%args) {
	# Factory method to create nodes based on type
	given $type {
		when 'VarDeclNode'		{ Xenober16::AST::VarDeclNode.new(|%args, :source-line($src)); 		}
		when 'ParamDeclNode'	{ Xenober16::AST::ParamDeclNode.new(|%args, :source-line($src)); 	}
		when 'ConstDeclNode'	{ Xenober16::AST::ConstDeclNode.new(|%args, :source-line($src)); 	}
		default 				{ die "Unknown node type: $type"; 		}
	}
}