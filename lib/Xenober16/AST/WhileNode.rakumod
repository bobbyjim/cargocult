use Xenober16::AST::ASTNode;

unit class Xenober16::AST::WhileNode is Xenober16::AST::ASTNode;

has $.condition is required;
has @.body is required;

method gist() {
    my $str = "WHILE " ~ $.condition.gist ~ " DO\n";
    $str ~= "  " ~ .gist ~ "\n" for @.body;
    $str ~ "END";
}
