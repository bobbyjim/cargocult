use Xenober16::AST::ASTNode;

unit class Xenober16::AST::IdentifierNode is Xenober16::AST::ASTNode;

has Str $.name is required;

method gist() {
    $.name;
}
