unit class Xenober16::Builder::NodeFactory;

class ASTNode { 
	method node-type { self.WHAT.perl }
}

class IdentifierNode is ASTNode {
	has Str $.name;
	method Str() { "IdentifierNode(name => '$.name')" }
	method dump($indent="") {
		say $indent ~ "IdentifierNode: '$.name'";
	}
}

class ModuleNode is ASTNode {
	has IdentifierNode $.id;
	method Str() { "ModuleNode(id => '$.id')" }

	method dump($indent="") {
		say $indent ~ "ModuleNode:";
		say $indent ~ "  id: " ;
		$!id.dump($indent ~ "   ");
	}
}

method new-module($id) {
	ModuleNode.new(:$id);
}

method new-identifier($name) {
	IdentifierNode.new(:$name);
}
