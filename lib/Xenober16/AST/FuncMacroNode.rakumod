use Xenober16::AST::ASTNode;

unit class Xenober16::AST::FuncMacroNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has @.parameters = [];
has Str $.return_type;
has @.body is required;

method gist() {
    my $str = "META " ~ $.name;
    if @.parameters {
        $str ~= "(" ~ @.parameters.map(*.gist).join(", ") ~ ")";
    }
    if $.return_type.defined {
        $str ~= " : " ~ $.return_type;
    }
    $str ~= "\n";
    $str ~= "  " ~ .gist ~ "\n" for @.body;
    $str ~ "END " ~ $.name;
}
