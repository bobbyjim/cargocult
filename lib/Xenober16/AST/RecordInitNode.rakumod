use Xenober16::AST::ASTNode;

unit class Xenober16::AST::RecordInitNode is Xenober16::AST::ASTNode;

has @.fields is required;

method gist() {
    "RECORD { " ~ @.fields.map(*.gist).join(", ") ~ " }";
}
