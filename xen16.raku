# The frontend to xenober16
# raku xen16.raku tests/Test1.x16   # runs test 1
# runs: Grammar -> ASTBuilder -> Interpreter.
# optional: dumps AST
# optional: responds to module flags such as DEBUG.

use Xenober16::Grammar; # these classes should be in ./lib/Xenober16/
use Xenober16::ASTBuilder;
use Xenober16::Interpreter;

sub MAIN(Str $file, Bool :$debug = False, Bool :$no-run = False) {

	my $parser = Xenober16::Grammar;
	my $astBuilder = Xenober16::ASTBuilder.new;

	my $text = slurp $file;

	my $result = $parser.parse($text, :actions($astBuilder));

	unless $result {
		say "\n[❌ Parser failed to parse the file: $file]";
		exit 1;
	}

	my $ast = $result.made;
	unless $ast {
		say "\n[❌ AST Build failed]";
		say "Parse result exists but .made returned: ", $ast.perl;
		exit 1;
	}

	say "\n\e[32m[✅ AST Build successful.]\e[0m\n";
	
	if $debug {
		say $ast.perl;
	}

	unless $no-run {
		my $interpreter = Xenober16::Interpreter.new;
		$interpreter.run($ast);
	}
	
	exit 0;
}
