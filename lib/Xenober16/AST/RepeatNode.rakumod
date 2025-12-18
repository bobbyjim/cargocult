use Xenober16::AST::ASTNode;

unit class Xenober16::AST::RepeatNode is Xenober16::AST::ASTNode;

has @.body is required;
has $.condition is required;

method gist() {
    my $str = "REPEAT\n";
    $str ~= "  " ~ .gist ~ "\n" for @.body;
    $str ~ "UNTIL " ~ $.condition.gist;
}
