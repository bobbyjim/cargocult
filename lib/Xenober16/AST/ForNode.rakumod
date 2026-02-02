use Xenober16::AST::ASTNode;

unit class Xenober16::AST::ForNode is Xenober16::AST::ASTNode;

has $.variable;    # Loop variable (identifier)
has $.start;       # Start expression
has $.end;         # End expression  
has $.step;        # Optional step (default 1)
has @.body;        # Statements in loop body

method gist {
    "ForNode(var={$.variable}, {$.start}..{$.end}, body={@.body.elems} stmts)"
}
