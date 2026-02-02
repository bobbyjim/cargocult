use Xenober16::AST::ASTNode;

unit class Xenober16::AST::MemoryRefNode is Xenober16::AST::ASTNode;

has $.bank;      # Optional expression
has $.address;   # Expression

method gist() {
    my $bank = $.bank.defined ?? "BANK(" ~ $.bank.gist ~ ")" !! "RAM";
    $bank ~ "[" ~ $.address.gist ~ "]";
}
