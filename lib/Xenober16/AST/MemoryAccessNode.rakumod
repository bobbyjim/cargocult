use Xenober16::AST::ASTNode;

unit class Xenober16::AST::MemoryAccessNode is Xenober16::AST::ASTNode;

has $.access-type;   # 'RAM' or 'BANK'
has $.address;       # Expression for address
has $.bank;          # Bank number (for BANK access)
has $.index;         # Optional index expression for array-style access

method gist {
    if $.access-type eq 'RAM' {
        "MemoryAccessNode(RAM[{$.address}])"
    } else {
        "MemoryAccessNode(BANK({$.bank})[{$.address}])"
    }
}
