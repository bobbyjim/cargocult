use Xenober16::AST::ASTNode;

unit class Xenober16::AST::IfNode is Xenober16::AST::ASTNode;

has $.condition is required;
has @.then-branch is required;
has @.elsif-branches = [];
has @.else-branch;

method gist() {
    my $str = "IF " ~ $.condition.gist ~ " THEN\n";
    $str ~= "  " ~ .gist ~ "\n" for @.then-branch;
    for @.elsif-branches -> $elsif {
        $str ~= "ELSIF " ~ $elsif<condition>.gist ~ " THEN\n";
        $str ~= "  " ~ .gist ~ "\n" for @($elsif<body>);
    }
    if @.else-branch {
        $str ~= "ELSE\n";
        $str ~= "  " ~ .gist ~ "\n" for @.else-branch;
    }
    $str ~ "END";
}
