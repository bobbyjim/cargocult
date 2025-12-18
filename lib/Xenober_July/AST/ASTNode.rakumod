unit role Xenober16::AST::ASTNode;

	has Int $.source-line = -1;

	method node-type { self.WHAT.perl }
	method line-info { " (line: $.source-line)" }

