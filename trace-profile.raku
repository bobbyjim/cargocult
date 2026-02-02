use lib 'lib';
use Xenober16::Grammar;

# Parse with tracing to see which rules are hit most
my $text = slurp 'test-files/common/test-10-FOR.xen';

say "Parsing test-10-FOR.xen (36 lines)...";
my $start = now;
my $result = Xenober16::Grammar.parse($text);
my $ms = ((now - $start) * 1000).round(2);

say "Parse time: $ms ms";
say "Result: {$result ?? 'SUCCESS' !! 'FAILED'}";
