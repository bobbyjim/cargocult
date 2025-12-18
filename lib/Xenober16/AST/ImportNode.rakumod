use Xenober16::AST::ASTNode;

unit class Xenober16::AST::ImportNode is Xenober16::AST::ASTNode;

has Str $.module is required;

method gist() {
    "USE " ~ $.module;
}
