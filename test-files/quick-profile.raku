use lib 'lib';
use Xenober16::Grammar;

my $file = @*ARGS[0];
my $text = slurp $file;

say "Profiling: $file ({$text.lines.elems} lines)";

my $parser = Xenober16::Grammar;

# Warm up
$parser.parse($text);

# Time it
my $start = now;
my $result = $parser.parse($text);
my $elapsed = now - $start;

printf "Parse time: %.2f ms\n", $elapsed * 1000;
printf "Result: %s\n", $result ?? "✅ SUCCESS" !! "❌ FAILED";
