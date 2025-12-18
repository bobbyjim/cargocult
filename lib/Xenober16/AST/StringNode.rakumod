use Xenober16::AST::ASTNode;

unit class Xenober16::AST::StringNode is Xenober16::AST::ASTNode;

has Str $.value is required;

method gist() {
    '"' ~ $.value ~ '"';
}
