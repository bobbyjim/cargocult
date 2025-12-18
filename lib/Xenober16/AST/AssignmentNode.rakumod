use Xenober16::AST::ASTNode;

unit class Xenober16::AST::AssignmentNode is Xenober16::AST::ASTNode;

has $.target is required;
has $.expression is required;

method gist() {
    $.target.gist ~ " := " ~ $.expression.gist;
}
