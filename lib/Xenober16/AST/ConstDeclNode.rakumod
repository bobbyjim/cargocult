use Xenober16::AST::ASTNode;

unit class Xenober16::AST::ConstDeclNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has Str $.vtype is required;
has $.value is required;

method gist() {
    $.name ~ ": " ~ $.vtype ~ " = " ~ $.value.gist;
}
