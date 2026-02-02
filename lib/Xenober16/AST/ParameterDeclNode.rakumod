use Xenober16::AST::ASTNode;

unit class Xenober16::AST::ParameterDeclNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has Str $.type is required;
has $.default-value;

method gist() {
    my $str = "PARAM " ~ $.name ~ " : " ~ $.type;
    $str ~= " := " ~ $.default-value.gist if $.default-value.defined;
    $str;
}
