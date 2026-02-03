#!/usr/bin/env raku
use Xenober16::Grammar;
use Xenober16::ASTBuilder;

my $testdir = "test-files/common";
my @tests = dir($testdir, test => /\.xen$/).sort;

say "🧪 AST Builder Test Suite";
say "=" x 50;
say "";

my $passed = 0;
my $failed = 0;

for @tests -> $test_file {
    my $filename = $test_file.IO.basename;
    
    my $text = slurp $test_file;
    my $r = Xenober16::Grammar.parse($text);
    
    if !$r {
        say "❌ $filename - Parse failed";
        $failed++;
        next;
    }
    
    try {
        my $ast = Xenober16::ASTBuilder.new.TOP($r);
        say "✅ $filename";
        $passed++;
        CATCH {
            default {
                say "❌ $filename - AST build failed: {$_}";
                $failed++;
            }
        }
    }
}

say "";
say "=" x 50;
say "Results: ✅ $passed passed, ❌ $failed failed";
say "Total: {$passed + $failed} tests";
