use Xenober16::AST::ASTNode;

unit class Xenober16::AST::MemoryAreaNode is Xenober16::AST::ASTNode;

has Str $.name is required;
has Str $.area-type is required;  # 'RAM' or 'BANK'
has Int $.size is required;
has Int $.address;  # For RAM
has Int $.bank;     # For BANK
has Int $.bank-address;  # For BANK

method gist() {
    my $str = "AREA " ~ $.name ~ " ";
    if $.area-type eq 'RAM' {
        $str ~= "RAM \$" ~ $.address.base(16);
    } else {
        $str ~= "BANK " ~ $.bank ~ " \$" ~ $.bank-address.base(16);
    }
    $str ~ " SIZE " ~ $.size;
}
