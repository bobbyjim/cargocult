use Xenober16::AST::ASTNode;

unit class Xenober16::AST::NumberLiteralNode is Xenober16::AST::ASTNode;

has Int $.value is required;
has Int $.radix = 10;

method gist() {
    $.radix == 16 ?? "\$" ~ $.value.base(16) !! ~$.value;
}
