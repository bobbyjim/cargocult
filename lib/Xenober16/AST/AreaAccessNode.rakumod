use Xenober16::AST::ASTNode;

unit class Xenober16::AST::AreaAccessNode is Xenober16::AST::ASTNode;

has $.area-name;   # Name of the memory area (e.g., 'screen')
has $.index;       # Index expression (e.g., [i])

method gist {
    "@" ~ $.area-name ~ "[" ~ $.index ~ "]"
}
