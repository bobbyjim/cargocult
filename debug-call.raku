use v6;
use lib 'lib';
use Xenober16::Grammar;
use Xenober16::ASTBuilder;

my $input = "greet(42);";

my $match = Xenober16::Grammar.parse($input, :rule<procedure-call>, :actions(Xenober16::ASTBuilder.new));

if $match {
    say "Match: YES";
    say $match.gist;
    say "AST: ", $match.made.raku;
} else {
    say "Match: NO";
}
