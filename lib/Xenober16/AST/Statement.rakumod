
unit module Xenober16::AST::Statement;
use Xenober16::AST::Node;
use Xenober16::AST::Expression;

class Assignment is Xenober16::AST::Node {
	has $.target;
	has $.expression;
}

class Say is Xenober16::AST::Node {
	has $.expression;
}
