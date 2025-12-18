use lib 'lib';
use Xenober16::Grammar;
use Xenober16::ASTBuilder;

my $text = "value + 5";

my $parser = Xenober16::Grammar;
my $astBuilder = Xenober16::ASTBuilder.new;

my $result = $parser.parse($text, :rule<sum>, :actions($astBuilder));

say "Match: ", $result ?? "YES" !! "NO";
if $result {
    say "AST: ", $result.made.perl if $result.made;
}
