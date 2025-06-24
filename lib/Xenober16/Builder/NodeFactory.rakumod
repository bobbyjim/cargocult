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

class IdentificationDivisionNode does ASTNode {
	has IdentifierNode $.module-id;
	has $.author = Nil;
	has $.date = Nil;
	has $.description = Nil;

	method Str() {
		my $id = $!module-id ?? $!module-id.Str !! "(no module-id)";
		"IdentificationDivisionNode(module-id => $id)"
	}

    method dump($indent = "") {
        say $indent ~ "IdentificationDivisionNode:";
        say $indent ~ "  module-id: ";
        $!module-id.dump($indent ~ "    ");
        say $indent ~ "  author: " ~ ($!author // '(none)');
        say $indent ~ "  date: " ~ ($!date // '(none)');
        say $indent ~ "  description: " ~ ($!description // '(none)');
        say $indent ~ self.line-info;
	}
}

class ModuleNode does ASTNode {
	has IdentificationDivisionNode $.metadata;
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

class VarDeclNode does ASTNode {
	has IdentifierNode $.name;
	has Str $.type;
	has Any $.init = Nil;  # Optional initialization expression

	method Str() { "VarDeclNode(name => '$.name', type => '$.type', init => '$.init')" }

	method dump($indent="") {
		say $indent ~ "VarDeclNode:";
		say $indent ~ "  name: " ~ $.name.name;
		say $indent ~ "  type: " ~ $.type;
		say $indent ~ "  init: " ~ ($!init // 'Nil');
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
		when 'ModuleNode' 		{ ModuleNode.new(|%args, :source-line($src)); 		}
		when 'IdentifierNode' 	{ IdentifierNode.new(|%args, :source-line($src));  	}
		when 'VarDeclNode'		{ VarDeclNode.new(|%args, :source-line($src)); 		}
		when 'SayNode'			{ SayNode.new(|%args, :source-line($src)); 			}
		when 'IdentificationDivisionNode' {
			IdentificationDivisionNode.new(|%args, :source-line($src));
		}
		default 				{ die "Unknown node type: $type"; 		}
	}
}
