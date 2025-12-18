unit class Xenober16::AST::ASTNode;

# Base class for all AST nodes
# All node types inherit from this to support visitor patterns and multi-dispatch

method gist() {
    self.perl;
}
