use Xenober16::AST::ASTNode;

unit class Xenober16::AST::IdentifierNode does ASTNode;

has Str $.name;

method Str() { "IdentifierNode(name => '$.name')" }

method dump($indent="") {
	say $indent ~ "IdentifierNode: '$.name'" ~ self.line-info;
}
