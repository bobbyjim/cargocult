use v6;
use lib '../lib';
use Xenober16::Grammar;

my $input = "value + 5";

my $match = Xenober16::Grammar.parse($input, :rule<sum>);

if $match {
    say "Match: YES";
    say "First product: ", $match<product>.Str;
    say "Repetition groups: ", $match.list.elems;
    for $match.list.flat -> $m {
        say "  Match str: '", $m.Str, "'";
        say "  Match list: ", $m.list.raku;
        say "  Match[0]: '", $m[0].Str, "'" if defined $m[0];
        say "  Match<product>: '", $m<product>.Str, "'" if $m<product>;
        # Try to extract operator
        my $str = $m.Str;
        if $str ~~ /^(\S+)\s+/ {
            say "  Operator via regex: '$0'";
        }
    }
} else {
    say "Match: NO";
}
