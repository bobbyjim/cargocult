use Xenober16::AST::ASTNode;

unit class Xenober16::AST::RecordNode is Xenober16::AST::ASTNode;

has $.name;        # Record type name (if named)
has @.fields;      # Array of field definitions (VarDeclNode or BitfieldNode)
has $.size;        # Total size in bytes (calculated)
has $.alignment;   # Alignment requirement

method gist {
    "RecordNode({$.name // 'anonymous'}, {self.field-count} fields, {$.size // '?'} bytes)"
}

method field-count {
    @.fields.elems
}

# Calculate total size and bitfield packing
method calculate-layout {
    my $offset = 0;
    my $bit-offset = 0;
    my $current-bitfield-byte = 0;
    
    for @.fields -> $field {
        if $field.isa('Xenober16::AST::BitfieldNode') {
            # Handle bitfield packing
            if $bit-offset + $field.width > ($current-bitfield-byte == 0 ?? 8 !! 16) {
                # Need new byte/word
                $offset += $current-bitfield-byte == 0 ?? 1 !! 2;
                $bit-offset = 0;
                $current-bitfield-byte = $field.width > 8 ?? 2 !! 1;
            }
            $field.offset = $bit-offset;
            $bit-offset += $field.width;
        } else {
            # Regular field - align and add
            if $bit-offset > 0 {
                $offset += $current-bitfield-byte;
                $bit-offset = 0;
                $current-bitfield-byte = 0;
            }
            $offset += self!type-size($field.vtype);
        }
    }
    
    # Add final bitfield bytes if any
    if $bit-offset > 0 {
        $offset += $current-bitfield-byte;
    }
    
    $!size = $offset;
}

method !type-size($type) {
    given $type {
        when 'uint8' | 'int8' | 'char' { 1 }
        when 'uint16' | 'int16' { 2 }
        default { 2 }  # Default to 2 bytes
    }
}
