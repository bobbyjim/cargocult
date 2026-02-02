use lib '../lib';
use Xenober16::Grammar;
use Xenober16::ASTBuilder;

my $text = "message := 65;";
my $parser = Xenober16::Grammar;
my $astBuilder = Xenober16::ASTBuilder.new;

my $result = $parser.parse($text, :rule<assignment>, :actions($astBuilder));

say "Match: ", $result ?? "YES" !! "NO";
say "Result: ", $result.perl;
say "Made: ", $result.made.perl if $result;
