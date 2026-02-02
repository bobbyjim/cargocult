#!/usr/bin/env raku
# AST Test Runner - Tests parsing AND AST building
# Validates that test files parse correctly and build proper ASTs

use lib '../../lib';
use Xenober16::Grammar-LL1;
use Xenober16::ASTBuilder-LL1;

sub MAIN(Bool :$verbose = False) {
    my $common-dir = $*PROGRAM.parent.parent.add('common');
    my @test-files = dir($common-dir).grep({ .f && .extension eq 'xen' }).sort;

    my $passed = 0;
    my $failed = 0;
    my @failures;

    say "🧪 LL(1) AST Test Suite";
    say "Testing parse + ASTBuilder validation";
    say "=" x 60;

    for @test-files -> $test-file {
        my $test-name = $test-file.basename;

        try {
            my $text = slurp $test-file;
            my $parser = Xenober16::Grammar-LL1;
            my $builder = Xenober16::ASTBuilder-LL1;
            my $result = $parser.parse($text, actions => $builder);

            if $result && $result.made {
                say "✅ PASSED  $test-name";
                $passed++;
            } else {
                say "❌ FAILED  $test-name (parse or AST build failed)";
                $failed++;
                @failures.push($test-name);
                say "  Error: Parse failed or AST not built" if $verbose;
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