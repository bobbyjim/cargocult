use Xenober16::AST::ASTNode;

unit class Xenober16::AST::BitfieldNode is Xenober16::AST::ASTNode;

has $.name;        # Field name
has $.width;       # Number of bits (1-15)
has $.offset;      # Bit offset within container (calculated)
has $.container;   # Parent record/struct

method gist {
    "BitfieldNode({$.name}, {$.width} bits @ offset {$.offset // 0})"
}

# Calculate the storage type needed
method storage-type {
    given $.width {
        when 1..8  { 'uint8' }
        when 9..15 { 'uint16' }
        default    { die "Invalid bitfield width: {$.width}" }
    }
}

# Generate bit mask for this field
method mask {
    (1 +< $.width) - 1
}
