unit class Xenober16::ASTBuilder;

use Xenober16::Builder::NodeFactory;

has $.node-factory = Xenober16::Builder::NodeFactory.new; # inject the NodeFactory

method trace($msg) {        # to control the debug output
	say $msg, "\n";
}

method TOP($/) {
	my $id-node = $<identification-division>.made;

    my @vars = $<data-division> ?? $<data-division>.made !! ();
    my @stmts = $<code-division> ?? $<code-division>.made !! ();

	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build(
		'ModuleNode', 
		:metadata($id-node), 
		:vars(@vars), 
		:statements(@stmts), 
		:src($line));


	self.trace("TOP: Created ModuleNode with id={$id-node}, vars={@vars}, stmts={@stmts}");
	make $node;
}

method identification-division($/) {
	my $module-id = $<module-id>.made;
	my $parameters = $<parameters-line> ?? $<parameters-line><param-decl> !! [];

	my $author = $<author-line> ?? ~$<author-line><text-line> !! Nil;
	my $date = $<date-line> ?? ~$<date-line><text-line> !! Nil;
	my $description = $<description-line> ?? ~$<description-line><text-line> !! Nil;
	my $license = $<license-line> ?? ~$<license-line><text-line> !! Nil;

	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build(
		'ID_DivisionNode',
		:module-id($module-id),
		:parameters($parameters),
		:author($author),
		:date($date),
		:description($description),
		:license($license),
		:src($/.orig.substr(0, $/.from).lines.elems)
	);
	self.trace("Created ID_DivisionNode: $node");
	make $node;
}

method module-id($/) {
	make $<identifier>.made;
}

method parameters-line($/) {
	my @params = $<param-decl>.map(*.made);
	#self.trace("Parameters in parameter list: {@params.perl}");
	make @params;
}

method param-decl($/) {
	#self.trace("Building param-decl: $/");
	my $name = $<identifier>.made;
	my $type = ~$<type-name>;
	my $line = $/.orig.substr(0, $/.from).lines.elems;
	die "❌ param-decl missing type at line $line" unless $type.defined && $type ne '';

	my $default = $<expression> ?? $<expression>.made !! Nil;  # Handle optional expression

	my $node = $.node-factory.build(
		'ParamDeclNode', 
		:name($name), 
		:type($type), 
		:default($default), 
		:src($line));
	#self.trace("Created ParamDeclNode: $node name($name) type($type) default({$default}) src($line)");
	make $node;
}

method identifier($/) {
	#self.trace("Building identifier: $/");
	my $name = ~$/;
	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build('IdentifierNode', :name($name), :src($line));
	#self.trace("Created IdentifierNode: $node");
	make $node;
}

method data-division($/) {
    my @vars   = $<working-storage-section> ?? $<working-storage-section>.made !! ();
    # @vars is something like ( [VarDeclNode, VarDeclNode,...] )

    # Flatten it so @vars is a flat list of VarDeclNodes:
    my @flat = flat @vars;
    self.trace("Flattened data-division: {@flat.perl}");
    make @flat;
}

method working-storage-section($/) {
    # Instead of mapping made on each var-decl separately, just do:
    my @vars = $<var-decl>.map(*.made);
    self.trace("Variables in working-storage-section: {@vars.perl}");
    make @vars.flat;
}

method var-decl($/) {
	#self.trace("Building var-decl: $/");
	my $name = $<identifier>.made;
	my $type = ~$<type-name>;
    my $init = $<expression> ?? $<expression>.made !! Nil;  # Handle optional expression

	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build(
		'VarDeclNode', 
		:name($name), 
		:type($type), 
		:init($init), 
		:src($line));
	self.trace("Created VarDeclNode: $node, name($name), type($type), init({$init}), src($line)");
	make $node;
}

method expression($/) {
	self.trace("Building expression: $/");
	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $expr-match = $<int-literal> // $<identifier>;

    # If it's a Seq (multiple matches), just take the first one
    if $expr-match ~~ Seq {
        $expr-match = $expr-match[0];
    }

	if $expr-match ~~ $<int-literal> {
		my $value = +$expr-match;
		my $node = $.node-factory.build('IntLiteralNode', :value($value), :src($line));
		#self.trace("Created IntLiteralNode: $node");
		make $node;
	} 
	elsif $expr-match ~~ $<identifier> {
		make $expr-match.made;
	} 
	else {
		self.trace("Unknown expression type: $/");
		die "Unknown expression type";
	}
}

method int-literal($/) {
	#self.trace("Building int-literal: $/");
	make +$/;
}

method code-division($/) {
	#self.trace("Building code-division: $/");
	my @stmts = $<statement>».made;
	self.trace("Statements in code-division: {@stmts}");
	make @stmts;
}

method statement($/) {
	self.trace("Building statement: $/");

	# The first key will be 'statement-singleton'
	if $/<statement-singleton>.defined {
		self.trace("Found statement-singleton: $/");
		my $stmt = $/<statement-singleton>;

		for $stmt.keys -> $key {
			my $submatch = $stmt{$key};
			self.trace("Trying inner statement key: $key, defined? {$submatch.defined}");
			if $submatch.defined {
				self.trace("Matched statement type: $key");
				make $submatch.made;
				return;
			}
		}
	}
	die "Unknown statement type at line {$/.orig.substr(0, $/.from).lines.elems}";
}

method say-statement($/) {
	#self.trace("Building say-statement: $/");
	my $expr = $<expression>.made;
	#self.trace("Expression: {$expr}");
	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build('SayNode', :expr($expr), :src($line));
	self.trace("Created SayNode: $node");
	make $node;
}

method proc-body($/) {
	#self.trace("Building proc-body: $/");
	my @stmts = $<statement> ?? $<statement>».made.list !! ();
	self.trace("Statements in proc-body: {@stmts}");
	make @stmts;
}

method pragma-list($/) {
	#self.trace("Building pragma-list: $/");
	my @pragmas = $<pragma>».made;
	self.trace("Pragmas in pragma-list: {@pragmas}");
	make @pragmas;
}

method pragma($/) {
	#self.trace("Building pragma: $/");
	my $name = ~$<identifier>;
	my $arg = $<expression> ?? $<expression>.made !! Nil;  # Handle optional argument

	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build(
		'PragmaNode', 
		:name($name), 
		:arg($arg), 
		:src($line));
	self.trace("Created PragmaNode: $node");
	make $node;
}

method proc-decl($/) {
	self.trace("Building proc-decl: $/");

    my $name        = $<identifier>.made;
    my @params      = $<param-decl-list>».made // [];
    my $return-type = $<type-name> ?? $<type-name>.made !! Nil;
    my @pragmas     = $<pragma-decl-list>».made // [];
    my @body        = $<proc-body><statement>».made // [];

    #self.trace("Params: {@params}");
    #self.trace("Return type: {$return-type // 'None'}");
    #self.trace("Pragmas: {@pragmas}");
    #self.trace("Body: {@body}");

    make Xenober16::AST::ProcDeclNode.new(
        name         => $name,
        params       => @params,
        pragmas      => @pragmas,
        return-type  => $return-type,
        body         => @body,
        source-line  => +$/ .line,
    );
}

method return-statement($/) {
	self.trace("Building return-statement: $/");
	my $expr = $<expression> ?? $<expression>.made !! Nil;
	my $line = $/.orig.substr(0, $/.from).lines.elems;
	my $node = $.node-factory.build('ReturnNode', :expr($expr), :src($line));
	self.trace("Created ReturnNode: $node");
	make $node;
}

method call-statement($/) {
	self.trace("Building call-statement: $/");

	my $target = $<identifier>.made;
	my @args = $<expression>:exists ?? $<expression>».made !! ();
	
	my $line = $/.orig.substr(0, $/.from).lines.elems;

	my $node = $.node-factory.build(
		'CallNode', 
		:target($target), 
		:args(@args), 
		:src($line));

	self.trace("Created CallNode: $node");
	make $node;
}