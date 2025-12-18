use Xenober16::AST::ASTNode;

unit class Xenober16::AST::BinaryOpNode is Xenober16::AST::ASTNode;

has Str $.op is required;
has $.left is required;
has $.right is required;

method gist() {
    "(" ~ $.left.gist ~ " " ~ $.op ~ " " ~ $.right.gist ~ ")";
}
