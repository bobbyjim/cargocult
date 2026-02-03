use Xenober16::AST::ASTNode;

unit class Xenober16::AST::EnumValueNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has Int $.value;

method gist() {
    $.value.defined ?? "ENUM " ~ $.name ~ " = " ~ $.value !! "ENUM " ~ $.name;
}
