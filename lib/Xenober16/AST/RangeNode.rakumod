use Xenober16::AST::ASTNode;

unit class Xenober16::AST::RangeNode is Xenober16::AST::ASTNode;

has $.start is required;   # numeric or string
has $.end   is required;

method gist() {
    $.start ~ ".." ~ $.end;
}
