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

class ID_DivisionNode does ASTNode {
	has IdentifierNode $.module-id;
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

class ParamDeclNode does ASTNode {
	has IdentifierNode $.name;
	has Str $.type;
	has Any $.default = Nil;  # Optional initialization expression

	method Str() { 
		"ParamDeclNode(name => '" ~ $.name.name ~ "', type => '" ~ $.type.trim ~ "', default => " ~
		($!default.defined ?? $!default.Str !! 'Nil') ~ ")"
	}

	method dump($indent="") {
		say $indent ~ "ParamDeclNode:";
		say $indent ~ "  name: " ~ $.name.name;
		say $indent ~ "  type: " ~ $.type;
		if $!default.defined {
			say $indent ~ "  default:";
			$!default ~~ ASTNode ?? $!default.dump($indent ~ "    ") !! say $indent ~ "    $!default";
		} else {
			say $indent ~ "  default: (none)";
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

method build(Str $type, :$src = -1, *%args) {
	# Factory method to create nodes based on type
	given $type {
		when 'IntLiteralNode' 	{ IntLiteralNode.new(|%args, :source-line($src)) }
		when 'ModuleNode' 		{ ModuleNode.new(|%args, :source-line($src)); 		}
		when 'IdentifierNode' 	{ IdentifierNode.new(|%args, :source-line($src));  	}
		when 'VarDeclNode'		{ VarDeclNode.new(|%args, :source-line($src)); 		}
		when 'SayNode'			{ SayNode.new(|%args, :source-line($src)); 			}
		when 'ParamDeclNode'	{ ParamDeclNode.new(|%args, :source-line($src)); 	}
		when 'ID_DivisionNode'  { ID_DivisionNode.new(|%args, :source-line($src));  }
		default 				{ die "Unknown node type: $type"; 		}
	}
}
