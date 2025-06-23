unit class Xenober16::Builder::NodeFactory;

role ASTNode { 
	has Int $.source-line = -1;

	method node-type { self.WHAT.perl }
	method line-info { " (line: $.source-line)" }
}

class IdentifierNode does ASTNode {
	has Str $.name;
	method Str() { "IdentifierNode(name => '$.name')" }
	method dump($indent="") {
		say $indent ~ "IdentifierNode: '$.name'" ~ self.line-info;
	}
}

class ModuleNode does ASTNode {
	has IdentifierNode $.id;
	method Str() { "ModuleNode(id => '$.id')" }

	method dump($indent="") {
		say $indent ~ "ModuleNode:";
		say $indent ~ "  id: " ;
		$!id.dump($indent ~ "   ");
		say $indent ~ self.line-info;
	}
}

method build(Str $type, :$src = -1, *%args) {
	# Factory method to create nodes based on type
	given $type {
		when 'ModuleNode' 		{ return ModuleNode.new(|%args, :source-line($src)); 		}
		when 'IdentifierNode' 	{ return IdentifierNode.new(|%args, :source-line($src));  	}
		default 				{ die "Unknown node type: $type"; 		}
	}
}
