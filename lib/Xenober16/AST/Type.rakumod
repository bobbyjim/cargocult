
unit module Xenober16::AST::Type;
use Xenober16::AST::Node;

class Scalar is Xenober16::AST::Node {
	has Str $.name; # e.g., "Int", "Str", etc.
} 

class ArrayType is Xenober16::AST::Node {
	has Str $.element-type; # e.g., "Int", "Str", etc.
	has Int $.length;         # Size of the array
}

class RecordType is Xenober16::AST::Node {
	has %!fields; # e.g., { "field1" => "Int", "field2" => "Str" }
	
	method fields() {
		return %!fields;
	}
}

class PointerType is Xenober16::AST::Node {
	has Str $.record-name; # e.g., name of the record this points to
}

class EnumType is Xenober16::AST::Node {
	has @.values; # e.g., ("Value1", "Value2", "Value3")
}

