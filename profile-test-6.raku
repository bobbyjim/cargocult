#!/usr/bin/env raku
# Profile test-6-PROC.xen in detail

use lib 'lib';
use Xenober16::Grammar-LL1;

my $test-file = "test-files/common/test-6-PROC.xen";
my $text = slurp $test-file;

say "🧪 Detailed Profile: test-6-PROC.xen";
say "=" x 70;
say "File size: {$text.chars} characters";
say "Lines: {$text.lines.elems}";
say "";

say "Parsing...";
say "-" x 70;

my $start = now;
my $result = Xenober16::Grammar-LL1.parse($text);
my $elapsed = now - $start;

say "Result: {$result ?? '✅ PASSED' !! '❌ FAILED'}";
printf "Total parse time: %.4fs\n", $elapsed;
printf "Time per character: %.6fms\n", ($elapsed / $text.chars) * 1000;
printf "Time per line: %.4fms\n", ($elapsed / $text.lines.elems);

if (!$result) {
    say "";
    say "Error details:";
    say $/.message;
}

say "";
say "=" x 70;

# Run it a few more times to see if there's variance
say "Timing stability (5 runs):";
say "-" x 70;

my @times;
for 1..5 -> $i {
    my $s = now;
    my $r = Xenober16::Grammar-LL1.parse($text);
    my $t = now - $s;
    @times.push($t);
    printf "Run %d: %.4fs\n", $i, $t;
}

say "";
my $avg = @times.sum / @times.elems;
my $min = @times.min;
my $max = @times.max;
printf "Average: %.4fs\n", $avg;
printf "Min: %.4fs\n", $min;
printf "Max: %.4fs\n", $max;
printf "Variance: %.4fs\n", $max - $min;
