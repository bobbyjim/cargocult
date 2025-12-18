
# You can just call:
# Xenober16::AST::Node.new(type => "Assignment", line => 12, column => 4)
class Xenober16::AST::Node {
	has Str $.type;
	has Int $.line;
	has Int $.column;

	method gist() {
		return "<{$!type} at line {$!line}, column {$!column}>";
	}
}
