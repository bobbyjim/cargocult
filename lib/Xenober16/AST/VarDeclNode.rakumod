use Xenober16::AST::ASTNode;

unit class Xenober16::AST::VarDeclNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has $.vtype is required;  # Can be Str or RecordNode
has Str $.area;

method gist() {
    my $type-str = $.vtype ~~ Str ?? $.vtype !! "record";
    $.name ~ ": " ~ $type-str ~ ($.area ?? " IN " ~ $.area !! "");
}
