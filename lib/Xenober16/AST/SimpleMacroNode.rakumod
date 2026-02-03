use Xenober16::AST::ASTNode;

unit class Xenober16::AST::SimpleMacroNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has Str $.type is required;
has $.value is required;

method gist() {
    "MACRO " ~ $.name ~ " : " ~ $.type ~ " IS " ~ $.value.gist;
}
