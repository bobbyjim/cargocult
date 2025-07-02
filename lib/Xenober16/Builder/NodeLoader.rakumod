unit module Xenober16::Builder::NodeLoader;

# Import all node classes to trigger INIT blocks
#use Xenober16::AST::ConstDeclNode;
#use Xenober16::AST::VarDeclNode;
#use Xenober16::AST::ParamDeclNode;

use Xenober16::Builder::Registry;

BEGIN {
#	Xenober16::Builder::Registry::register('ConstDeclNode', ::Xenober16::AST::ConstDeclNode);
#	Xenober16::Builder::Registry::register('VarDeclNode', ::Xenober16::AST::VarDeclNode);
#	Xenober16::Builder::Registry::register('ParamDeclNode', ::Xenober16::AST::ParamDeclNode);
}
