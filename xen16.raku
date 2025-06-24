# The frontend to xenober16
# raku xen16.raku tests/Test1.x16   # runs test 1
# runs: Grammar -> ASTBuilder -> Interpreter.
# optional: dumps AST
# optional: responds to module flags such as DEBUG.

use Xenober16::Parser; # these classes should be in ./lib/Xenober16/
use Xenober16::ASTBuilder;
use Xenober16::Interpreter;

sub MAIN(Str $file, Bool :$debug = False) {

	my $parser = Xenober16::Parser;
	my $astBuilder = Xenober16::ASTBuilder.new;

	my $text = slurp $file;

	my $result = $parser.parse($text, :actions($astBuilder), :trace($debug));

	unless $result {
		say "\n[❌ Parser failed to parse the file: $file]";
		exit 1;
	}

	my $ast = $result.made;
	say "AST: " ~ $ast.WHAT.perl if $debug;
	unless $ast {
		say "\n[❌ AST Build failed]";
		exit 1;
	}

    say $ast if $debug;
    $ast.dump if $debug;

	say "\n\e[32m[✅ AST Build successful.]\e[0m\n";
	my $interpreter = Xenober16::Interpreter.new;
 	$interpreter.run($ast);
	exit 0;
}
