use Xenober16::AST::ASTNode;

unit class Xenober16::AST::ParamDeclNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has Str $.ptype is required;

method gist() {
    $.name ~ ": " ~ $.ptype;
}
