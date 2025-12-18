use lib 'lib';
use Xenober16::Grammar;

my $text = "value + 5";
my $parser = Xenober16::Grammar;

my $result = $parser.parse($text, :rule<sum>);

say "Match: ", $result ?? "YES" !! "NO";
if $result {
    say "Result structure:";
    say "  \$<product>: ", $result<product>.perl;
    say "  \$/: ", $result.list.perl;
    say "  \$/[0]: ", $result[0].perl if $result[0];
    say "  \$/[1]: ", $result[1].perl if $result[1];
}
