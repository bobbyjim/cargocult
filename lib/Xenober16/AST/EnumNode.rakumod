use Xenober16::AST::ASTNode;

unit class Xenober16::AST::EnumNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has @.members is required;  # Array of {name => Str, value => Int}

method gist() {
    my $str = "ENUM " ~ $.name ~ "\n";
    for @.members -> $member {
        $str ~= "  " ~ $member<name>;
        $str ~= " = " ~ $member<value> if $member<value>.defined;
        $str ~= "\n";
    }
    $str ~= "END ENUM";
    $str;
}
