unit class Xenober16::Builder::NodeFactory;

#use Xenober16::Builder::NodeLoader;
#use Xenober16::Builder::Registry;

use Xenober16::AST::IdentifierNode;
use Xenober16::AST::ConstDeclNode;
use Xenober16::AST::ParamDeclNode;
use Xenober16::AST::VarDeclNode;
use Xenober16::AST::ID_DivisionNode;
use Xenober16::AST::IntLiteralNode;
use Xenober16::AST::ModuleNode;
use Xenober16::AST::SayNode;
#use Xenober16::AST::BinaryOpNode;
#use Xenober16::AST::AssignNode;
#use Xenober16::AST::IfNode;

#method buildFromRegistry(Str $name, %data) {
#	my $type = Xenober16::Builder::Registry.get($name)
#	 or die "❌ Unknown (perhaps un-imported?) node type: '$name'";
#	return $type.new(|%data, :source-line(%data<source-line> // -1));
#}

method build(Str $type, :$src = -1, *%args) {
	# Factory method to create nodes based on type
	given $type {
		# ─────── Core node types ───────
		when 'ID_DivisionNode'  { Xenober16::AST::ID_DivisionNode.new(|%args, :source-line($src));  }
		when 'IntLiteralNode' 	{ Xenober16::AST::IntLiteralNode.new(|%args, :source-line($src)) }
		# | 'BinaryOpNode'      

		when 'ModuleNode' 		{ Xenober16::AST::ModuleNode.new(|%args, :source-line($src)); 		}
		when 'IdentifierNode' 	{ Xenober16::AST::IdentifierNode.new(|%args, :source-line($src));  	}

		when 'SayNode'			{ Xenober16::AST::SayNode.new(|%args, :source-line($src)); 			}
		# 'AssignNode' | 'IfNode' 

		when 'ConstDeclNode'	{ Xenober16::AST::ConstDeclNode.new(|%args, :source-line($src)); }
		when 'ParamDeclNode'	{ Xenober16::AST::ParamDeclNode.new(|%args, :source-line($src)); }
		when 'VarDeclNode'		{ Xenober16::AST::VarDeclNode.new(|%args, :source-line($src)); }

		# ─────── Registered (fallback) ───────
		default { 
			say "Attempting to find type: '$type' imported to registry.";
			$.self.buildFromRegistry($type, |%args, :source-line($src))
		}
	}
}
