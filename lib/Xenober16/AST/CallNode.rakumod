use Xenober16::AST::ASTNode;

unit class Xenober16::AST::CallNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has @.arguments = [];

method gist() {
    $.name ~ "(" ~ @.arguments.map(*.gist).join(", ") ~ ")";
}
