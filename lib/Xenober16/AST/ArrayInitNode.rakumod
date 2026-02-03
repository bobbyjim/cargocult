use Xenober16::AST::ASTNode;

unit class Xenober16::AST::ArrayInitNode is Xenober16::AST::ASTNode;

has @.elements is required;

method gist() {
    "{ " ~ @.elements.map(*.gist).join(", ") ~ " }";
}
