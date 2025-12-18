use Xenober16::AST::ASTNode;

unit class Xenober16::AST::CaseNode is Xenober16::AST::ASTNode;

has $.selector is required;
has @.branches is required;
has @.else-branch = [];

method gist() {
    my $str = "CASE " ~ $.selector.gist ~ " OF\n";
    for @.branches -> $branch {
        $str ~= "  | ";
        $str ~= $branch<selectors>.map(*.gist).join(", ");
        $str ~= ":\n";
        $str ~= "    " ~ .gist ~ "\n" for @($branch<body>);
    }
    if @.else-branch {
        $str ~= "ELSE\n";
        $str ~= "  " ~ .gist ~ "\n" for @.else-branch;
    }
    $str ~ "END";
}
