# The frontend to xenober16
# raku xen16.raku tests/Test1.x16   # runs test 1
# runs: Grammar -> ASTBuilder -> Interpreter.
# optional: dumps AST
# optional: responds to module flags such as DEBUG.
# optional: transpiles to prog8

use Xenober16::Grammar; # these classes should be in ./lib/Xenober16/
use Xenober16::ASTBuilder;
use Xenober16::Interpreter;
use Xenober16::Prog8Transpiler;

sub MAIN(Str $file, Bool :$debug = False, Bool :$no-run = False, Str :$transpile = '') {

	my $parser = Xenober16::Grammar.new;
	my $astBuilder = Xenober16::ASTBuilder.new;

	my $text = slurp $file;

	my $result = $parser.parse($text, :actions($astBuilder));

	unless $result {
		say "\n[❌ Parser failed on file: $file]";
		
		# Get the position where parsing stopped
		my $pos = $parser.pos // 0;
		my @lines = $text.lines;
		my $total-chars = 0;
		my $line-num = 0;
		my $col-num = 0;
		my $error-line = '';
		
		# Find which line the error is on
		for @lines.kv -> $idx, $line {
			if $total-chars + $line.chars >= $pos {
				$line-num = $idx + 1;
				$col-num = $pos - $total-chars + 1;
				$error-line = $line;
				
				say "\n📍 Parse stopped at line $line-num, column $col-num:\n";
				
				# Show context (3 lines before and after)
				my $start = max(0, $idx - 2);
				my $end = min(@lines.elems - 1, $idx + 2);
				
				for $start .. $end -> $i {
					my $prefix = $i == $idx ?? '→ ' !! '  ';
					my $line-label = sprintf("%3d", $i + 1);
					say "$prefix$line-label | @lines[$i]";
					
					if $i == $idx {
						my $spaces = ' ' x ($col-num + 6);  # account for "→ NNN | "
						say "      | {$spaces}↑ here";
					}
				}
				
				last;
			}
			$total-chars += $line.chars + 1;  # +1 for newline
		}
		
		# If pos is 0 or very small, show more context
		if $pos <= 1 {
			say "\n💡 Parser failed immediately. Common issues:";
			say "   • PARAMETERS keyword might not be recognized - check grammar token definition";
			say "   • Invalid division header - should be exactly 'DIVISION.'";
			say "   • Encoding issues or special characters in the file";
			say "";
			say "First few lines of file:";
			for 0 .. min(4, @lines.elems - 1) -> $i {
				my $line-label = sprintf("%3d", $i + 1);
				say "  $line-label | @lines[$i]";
			}
		} else {
			say "\n💡 Tip: Check for missing semicolons, mismatched END statements, or typos in keywords.";
		}
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

	# Handle transpilation
	if $transpile {
		given $transpile.lc {
			when 'prog8' | 'p8' {
				my $transpiler = Xenober16::Prog8Transpiler.new;
				my $output = $transpiler.transpile($ast);
				say $output;
			}
			default {
				say "\n[❌ Unknown transpilation target: $transpile]";
				say "Available targets: prog8, p8";
				exit 1;
			}
		}
		exit 0;
	}

	unless $no-run {
		my $interpreter = Xenober16::Interpreter.new;
		$interpreter.run($ast);
	}
	
	exit 0;
}
