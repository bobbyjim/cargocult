#!/usr/bin/env raku
use Xenober16::Grammar;

my @failing = <test-12-MACRO test-13-memory-areas test-14-comprehensive-2 test-15-module-parameters test-6-PROC test-9-comprehensive-1 test-fib>;

for @failing -> $test {
    my $file = "test-files/common/$test.xen";
    say "=== $test ===";
    
    try {
        my $text = slurp $file;
        my $r = Xenober16::Grammar.parse($text);
        
        if $r {
            say "✅ PASS";
        } else {
            say "❌ FAIL";
            say $r.error if $r.error;
        }
    };
    
    if $! {
        say "❌ ERROR: " ~ $!.Str;
    }
    say "";
}
