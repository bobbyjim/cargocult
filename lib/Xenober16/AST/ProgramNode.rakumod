use Xenober16::AST::ASTNode;

unit class Xenober16::AST::ProgramNode is Xenober16::AST::ASTNode;

has $.identification is required;
has @.imports = [];
has @.constants = [];
has @.memory = [];
has @.data = [];
has @.procedures = [];
has @.main = [];

method gist() {
    my $str = "=== PROGRAM ===\n";
    $str ~= $.identification.gist;
    $str ~= "\n--- IMPORTS ---\n" ~ .gist ~ "\n" for @.imports;
    $str ~= "\n--- CONSTANTS ---\n" ~ .gist ~ "\n" for @.constants;
    $str ~= "\n--- MEMORY ---\n" ~ .gist ~ "\n" for @.memory;
    $str ~= "\n--- DATA ---\n" ~ .gist ~ "\n" for @.data;
    $str ~= "\n--- PROCEDURES ---\n" ~ .gist ~ "\n" for @.procedures;
    $str ~= "\n--- MAIN ---\n" ~ .gist ~ "\n" for @.main;
    $str;
}
