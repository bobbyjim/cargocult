use lib '../lib'; 
use Xenober15::Parser; # Ensure these modules or classes are in the './lib' directory
use Xenober15::ASTBuilder;
use Xenober15::Interpreter;

sub MAIN(Str $file) {

    say "\n****************************************************************************\n";
	say "\n   * * * * * *     Did you \"source setenv.sh\" first, Rob?     * * * * * *   \n";	
    say "\n****************************************************************************\n";

	my $parser = Xenober15::Parser;
	my $text = slurp $file;
	
	#say $parser.parse($text);

	my $result = $parser.parse($text, :actions(Xenober15::ASTBuilder.new), :trace);

	if !$result {
		say "\n[Parser failed to parse the file: $file]";
		#say "Error: " ~ $parser.parse-error;
		exit 1;
	}

	my $ast = $result.made;
	say $ast;

	say "\n[AST Build successful.  Running interpreter...]\n";
 	my $interpreter = Xenober15::Interpreter.new;
 	$interpreter.run($ast);
 	say "[Program executed successfully]";
	exit 0;
}
