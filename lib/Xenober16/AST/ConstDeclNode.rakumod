use Xenober16::AST::ASTNode;

unit class Xenober16::AST::ConstDeclNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has Str $.vtype;  # Optional - can be inferred
has $.value is required;

method gist() {
    $.name ~ ($.vtype ?? ": " ~ $.vtype !! "") ~ " = " ~ $.value.gist;
}
