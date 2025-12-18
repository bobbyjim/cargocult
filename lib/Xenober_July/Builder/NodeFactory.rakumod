unit class Xenober16::Builder::NodeFactory;

use Xenober16::AST::IdentifierNode;
use Xenober16::AST::ParamDeclNode;
use Xenober16::AST::VarDeclNode;
use Xenober16::AST::ID_DivisionNode;
use Xenober16::AST::IntLiteralNode;
use Xenober16::AST::ModuleNode;
use Xenober16::AST::SayNode;
use Xenober16::AST::ProcDeclNode;
use Xenober16::AST::PragmaNode;
use Xenober16::AST::ReturnNode;
use Xenober16::AST::CallNode;


#use Xenober16::AST::BinaryOpNode;
#use Xenober16::AST::AssignNode;
#use Xenober16::AST::IfNode;

method build(Str $type, :$src = -1, *%args) {

	my %registry = (
		'ParamDeclNode'  => Xenober16::AST::ParamDeclNode,
		'VarDeclNode'    => Xenober16::AST::VarDeclNode,
		'IdentifierNode' => Xenober16::AST::IdentifierNode,
		'ID_DivisionNode' => Xenober16::AST::ID_DivisionNode,
		'IntLiteralNode' => Xenober16::AST::IntLiteralNode,
		'ModuleNode'     => Xenober16::AST::ModuleNode,
		'SayNode'        => Xenober16::AST::SayNode,
		'ProcDeclNode'   => Xenober16::AST::ProcDeclNode,
		'PragmaNode'     => Xenober16::AST::PragmaNode,
		'ReturnNode'     => Xenober16::AST::ReturnNode,
		'CallNode'       => Xenober16::AST::CallNode,
	);
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

		when 'ParamDeclNode'	{ Xenober16::AST::ParamDeclNode.new(|%args, :source-line($src)); }
		when 'VarDeclNode'		{ Xenober16::AST::VarDeclNode.new(|%args, :source-line($src)); }

		when 'ProcDeclNode'		{ 
			my $n = Xenober16::AST::ProcDeclNode.new(|%args, :source-line($src));
			# Build the disambiguation name for the procedure node
			# This is done here to ensure it is available immediately after creation
			$n.build-disambiguation-name;  
			$n;
		}
		when 'PragmaNode'		{ Xenober16::AST::PragmaNode.new(|%args, :source-line($src)) }
		when 'ReturnNode'		{ Xenober16::AST::ReturnNode.new(|%args, :source-line($src)) }
		when 'CallNode'			{ Xenober16::AST::CallNode.new(|%args, :source-line($src)) }

		# ─────── Registered (fallback) ───────
		default { 
			say "Attempting to find type: '$type' imported to registry.";
			my $class = %registry{$type} or die "Unknown node type: '$type'";
			$class.new(|%args, :source-line($src));
		}
	}
}
