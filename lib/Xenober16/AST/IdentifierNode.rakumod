use Xenober16::AST::ASTNode;

unit class Xenober16::AST::IdentifierNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has @.indices = [];

method gist() {
    my $str = $.name;
    $str ~= "[" ~ .gist ~ "]" for @.indices;
    $str;
}
