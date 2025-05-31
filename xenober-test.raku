use lib './lib'; 
use Xenober16::Parser; # Ensure these modules or classes are in the './lib' directory
use Xenober16::ASTBuilder;
use Xenober16::Interpreter;

sub MAIN(Str $file) {
	my $parser = Xenober16::Parser;
	my $text = slurp $file;
	
	#say $parser.parse($text);

	my $result = $parser.parse($text, :actions(Xenober16::ASTBuilder.new), :trace);

	if !$result {
		say "\n[Parser failed to parse the file: $file]";
		#say "Error: " ~ $parser.parse-error;
		exit 1;
	}

	my $ast = $result.made;
	say $ast;

	say "\n[AST Build successful.  Running interpreter...]\n";
 	my $interpreter = Xenober16::Interpreter.new;
 	$interpreter.run($ast);
 	say "[Program executed successfully]";
	exit 0;
}
