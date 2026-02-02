#!/usr/bin/env raku
# Grammar Test Runner - Tests ONLY parsing (no ASTBuilder)
# Validates that all test files parse correctly according to the grammar

use lib '../lib';
use Xenober16::Grammar;

sub MAIN(Bool :$verbose = False) {
    my $common-dir = $*PROGRAM.parent.parent.add('common');
    my @test-files = dir($common-dir).grep({ .f && .extension eq 'xen' }).sort;
    
    my $passed = 0;
    my $failed = 0;
    my @failures;
    
    say "🧪 Grammar Test Suite";
    say "Testing parse-only (no ASTBuilder validation)";
    say "=" x 60;
    
    for @test-files -> $test-file {
        my $test-name = $test-file.basename;
        #print "Testing $test-name ... ";
        
        try {
            my $text = slurp $test-file;
            my $parser = Xenober16::Grammar;
            my $result = $parser.parse($text);
            
            if $result {
                say "✅ PASSED  $test-name";
                $passed++;
            } else {
                say "❌ FAILED  $test-name (parse error)";
                $failed++;
                @failures.push($test-name);
                say "  Error: Grammar did not match" if $verbose;
            }
            
            CATCH {
                default {
                    say "❌ FAILED  $test-name (exception)";
                    say "  {.message}" if $verbose;
                    $failed++;
                    @failures.push($test-name);
                }
            }
        }
    }
    
    say "=" x 60;
    say "Results: ✅ $passed passed, ❌ $failed failed";
    say "Total: {@test-files.elems} tests";
    
    if @failures {
        say "\nFailed tests:";
        for @failures -> $failure {
            say "  ❌ $failure";
        }
    }
    
    exit($failed == 0 ?? 0 !! 1);
}
