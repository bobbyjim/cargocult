use Xenober16::AST::ASTNode;

unit class Xenober16::AST::RangeNode is Xenober16::AST::ASTNode;

has Int $.start is required;
has Int $.end is required;

method gist() {
    $.start ~ ".." ~ $.end;
}
