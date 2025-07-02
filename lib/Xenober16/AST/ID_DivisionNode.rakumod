use Xenober16::AST::ASTNode;
use Xenober16::AST::IdentifierNode;

class Xenober16::AST::ID_DivisionNode does Xenober16::AST::ASTNode {

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