use Xenober16::AST::ASTNode;

unit class Xenober16::AST::EchoNode is Xenober16::AST::ASTNode;

has $.expression is required;

method gist() {
    "ECHO " ~ $.expression.gist;
}
