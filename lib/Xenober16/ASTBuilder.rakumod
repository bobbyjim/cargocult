unit class Xenober16::ASTBuilder;

use Xenober16::Builder::NodeFactory;

has $.node-factory = Xenober16::Builder::NodeFactory.new; # inject the NodeFactory

method trace($msg) {        # to control the debug output
	say $msg;
}

method TOP($/) {
	self.trace("TOP rule: $/");
	my $id-node = $<identification-division>.made;

    my @vars = $<data-division> ?? $<data-division>.made !! ();
    my @stmts = $<code-division> ?? $<code-division>.made !! ();

	self.trace("Building ModuleNode with id {$id-node}, vars: {@vars}, stmts: {@stmts}");

	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build(
		'ModuleNode', 
		:metadata($id-node), 
		:vars(@vars), 
		:statements(@stmts), 
		:src($line));

	self.trace("Created ModuleNode: $node");
	make $node;
}

method identification-division($/) {
	self.trace("Building identification-division: $/");
	my $module-id = $<module-id>.made;
	my $author = $<author-line> ?? ~$<author-line><text-line> !! Nil;
	my $date = $<date-line> ?? ~$<date-line><text-line> !! Nil;
	my $description = $<description-line> ?? ~$<description-line><text-line> !! Nil;
	my $license = $<license-line> ?? ~$<license-line><text-line> !! Nil;

	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build(
		'IdentificationDivisionNode',
		:module-id($module-id),
		:author($author),
		:date($date),
		:description($description),
		:license($license),
		:src($/.orig.substr(0, $/.from).lines.elems)
	);
	self.trace("Created IdentificationDivisionNode: $node");
	make $node;
}

method module-id($/) {
	self.trace("Building module-id: $/");
	make $<identifier>.made;
}


method identifier($/) {
	self.trace("Building identifier: $/");
	my $name = ~$/;
	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build('IdentifierNode', :name($name), :src($line));
	self.trace("Created IdentifierNode: $node");
	make $node;
}

method data-division($/) {
    # Get the working-storage-section node, which already makes an array of vars
    my $ws = $<working-storage-section>;
    my @vars = $ws ?? $ws.made !! ();
    self.trace("Variables in data-division (before flatten): {@vars.perl}");
    # @vars is something like ( [VarDeclNode, VarDeclNode,...] )

    # Flatten it so @vars is a flat list of VarDeclNodes:
    my @flat_vars = @vars.flat;
    self.trace("Variables in data-division (flattened): {@flat_vars.perl}");
    make @flat_vars;
}

method working-storage-section($/) {
    # Instead of mapping made on each var-decl separately, just do:
    my @vars = $<var-decl>.map(*.made);
    self.trace("Variables in working-storage-section: {@vars.perl}");
    make @vars.flat;
}

method var-decl($/) {
	self.trace("Building var-decl: $/");
	my $name = $<identifier>.made;
	my $type = ~$<type-name>;
    my $init = $<expression> ?? $<expression>.made !! Nil;  # Handle optional expression

	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build('VarDeclNode', :name($name), :type($type), :init($init), :src($line));
	self.trace("Created VarDeclNode: $node");
	make $node;
}

method expression($/) {
	self.trace("Building expression: $/");
	if $<int-literal> {
		make +$<int-literal>;
	} 
	elsif $<identifier> {
		make $<identifier>.made;
	} 
	else {
		self.trace("Unknown expression type: $/");
		die "Unknown expression type";
	}
}

method int-literal($/) {
	self.trace("Building int-literal: $/");
	make +$/;
}

method code-division($/) {
	self.trace("Building code-division: $/");
	my @stmts = $<statement>».made;
	self.trace("Statements in code-division: {@stmts}");
	make @stmts;
}

method statement($/) {
	self.trace("Building statement: $/");
	make $<say-statement>.made;
}

method say-statement($/) {
	self.trace("Building say-statement: $/");
	my $expr = $<expression>.made;
	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build('SayNode', :expr($expr), :src($line));
	self.trace("Created SayNode: $node");
	make $node;
}

