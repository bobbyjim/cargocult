unit class Xenober16::Builder::NodeFactory;

role ASTNode { 
	method node-type { self.WHAT.perl }
}

class IdentifierNode does ASTNode {
	has Str $.name;
	method Str() { "IdentifierNode(name => '$.name')" }
	method dump($indent="") {
		say $indent ~ "IdentifierNode: '$.name'";
	}
}

class ModuleNode does ASTNode {
	has IdentifierNode $.id;
	method Str() { "ModuleNode(id => '$.id')" }

	method dump($indent="") {
		say $indent ~ "ModuleNode:";
		say $indent ~ "  id: " ;
		$!id.dump($indent ~ "   ");
	}
}

method build(Str $type, *%args) {
	# Factory method to create nodes based on type
	given $type {
		when 'ModuleNode' 		{ return ModuleNode.new(|%args); 		}
		when 'IdentifierNode' 	{ return IdentifierNode.new(|%args);  	}
		default 				{ die "Unknown node type: $type"; 		}
	}
}
