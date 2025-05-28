use lib './lib'; 
use Xenober16::Parser; # Ensure these modules or classes are in the './lib' directory
use Xenober16::ASTBuilder;
use Xenober16::Interpreter;

sub MAIN(Str $file) {
	my $parser = Xenober16::Parser;
	my $text = slurp $file;
	
	my $result = $parser.parse($text, :actions(Xenober16::ASTBuilder.new), :trace);
	#say $result;

	# Check if the parse was successful
	if $result {
		my $ast = $result.made;
 	 	say $ast;
	 	my $interpreter = Xenober16::Interpreter.new;
	 	$interpreter.run($ast);
	 	say "Program executed successfully!";
	} else {
	 	say "Parse failed!";
	}

}
