
use Xenober16::AST::Node;
use Xenober16::AST::Type;

class Xenober16::AST::Program is Xenober16::AST::Node {
	has $.identification; # Could be another AST node or a structured object
	has @.imports;        # Array of import declarations
	has $.memory;         # Could be another AST node or a structured object
	has @.macros;         # Array of macro declarations
	has $.data;           # Could be another AST node or a structured object
	has $.procedure;      # Could be a Procedure AST node
	has $.main;           # Could be another AST node or a structured object

	method gist() {
		return "<Program with procedure {$!procedure.name}>";
	}
}
