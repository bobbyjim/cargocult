unit class Xenober16::ASTBuilder;

use Xenober16::Builder::NodeFactory;

has $.node-factory = Xenober16::Builder::NodeFactory.new; # inject the NodeFactory

method trace($msg) {        # to control the debug output
	say $msg;
}

method TOP($/) {
	self.trace("TOP rule: $/");
	my $result = $<identification-division>.made;
	self.trace("TOP made: $result");
	make $result;
}

method identification-division($/) {
	self.trace("Building identification-division: $/");
	my $result = $<module-id>.made;
	self.trace("Result from module-id: $result");
	make $result;
}

method module-id($/) {
	self.trace("Building module-id: $/");
	# Create a ModuleNode using the NodeFactory
	my $id = $<identifier>.made;
	self.trace("Identifier result: $id");
	#my $node = $.node-factory.new-module($id);
	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build('ModuleNode', :id($id), :src($line));
	self.trace("Created ModuleNode: $node");
	make $node;
}

method identifier($/) {
	self.trace("Building identifier: $/");
	# Create an IdentifierNode using the NodeFactory
	my $name = ~$/;
	#my $node = $.node-factory.new-identifier($name);
	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build('IdentifierNode', :name($name), :src($line));
	self.trace("Created IdentifierNode: $node");
	make $node;
}
