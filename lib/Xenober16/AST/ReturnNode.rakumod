use Xenober16::AST::ASTNode;

unit class Xenober16::AST::ReturnNode is Xenober16::AST::ASTNode;

has $.expr;

method gist() {
    "RETURN " ~ ($.expr ?? $.expr.gist !! "")
}
