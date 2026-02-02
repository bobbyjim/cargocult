use Xenober16::AST::ASTNode;

unit class Xenober16::AST::IdentificationNode is Xenober16::AST::ASTNode;

has Str $.module-id is required;
has @.parameters = [];
has Str $.author;
has Str $.description;
has Str $.purpose;

method gist() {
    my $str = "MODULE-ID. " ~ $.module-id ~ "\n";
    if @.parameters {
        $str ~= "  PARAMETERS:\n";
        for @.parameters -> $p {
            $str ~= "    {$p<name>}: {$p<type>} := {$p<default>.gist}\n";
        }
    }
    $str ~= "AUTHOR. " ~ $.author ~ "\n" if $.author;
    $str ~= "DESCRIPTION. " ~ $.description ~ "\n" if $.description;
    $str ~= "PURPOSE. " ~ $.purpose ~ "\n" if $.purpose;
    $str;
}
