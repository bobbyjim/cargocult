use Xenober16::AST::ASTNode;

unit class Xenober16::AST::SayNode is Xenober16::AST::ASTNode;

has $.expression is required;

method gist() {
    "SAY " ~ $.expression.gist;
}
