
unit module Xenober16::AST::Expression;
use Xenober16::AST::Node;

class Literal is Xenober16::AST::Node {
	has Str $.value;
}

class BinaryOp is Xenober16::AST::Node {
	has Str $.operator;
	has Xenober16::AST::Node $.left;
	has Xenober16::AST::Node $.right;
}

