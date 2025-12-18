use Xenober16::AST::ASTNode;

unit class Xenober16::AST::VarDeclNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has Str $.vtype is required;
has Str $.area;

method gist() {
    $.name ~ ": " ~ $.vtype ~ ($.area ?? " IN " ~ $.area !! "");
}
