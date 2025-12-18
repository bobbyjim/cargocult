
unit module Xenober16::AST::Declaration;
use Xenober16::AST::Node;
use Xenober16::AST::Type;

class Variable is Xenober16::AST::Node {
	has Str $.name;
	has Str $.type;
	has $.initial-value; # Could be an expression node or a literal value
}

class Procedure is Xenober16::AST::Node {
	has Str $.name;
	has @.parameters; # Array of parameter names
	has @.body;       # Array of statements (could be other AST nodes)
}

