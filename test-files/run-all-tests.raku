#!/usr/bin/env raku
# Master test runner for all test suites
# Runs grammar, AST, transpiler, and interpreter tests
# Reports pass/fail for each suite

use lib '../lib';

sub run-suite($name, $script, @args = []) {
    my $sep = "=" x 60;
    say "\n$sep";
    say "Running: $name";
    say $sep;
    
    my $result = run(|("raku", $script, |@args), :out, :err);
    my $out = $result.out.slurp(:close);
    my $err = $result.err.slurp(:close);
    
    if $result.exitcode == 0 {
        say "✅ PASSED: $name";
        return "PASSED";
    } else {
        say "❌ FAILED: $name";
        say "Error output:";
        say $err if $err;
        say $out if $out;
        return "FAILED";
    }
}

sub MAIN(Bool :$verbose = False) {
    my %results;
    
    say "🧪 XENOBER16 TEST SUITE";
    say "Running all test layers...";
    
    # Run Grammar tests
    %results<grammar> = run-suite("Grammar Tests", "grammar/debug-parse.raku", []);
    
    # Run AST tests (pick one representative debug script)
    %results<ast> = run-suite("AST Tests", "ast/debug-expr.raku", []);
    
    # Run Transpiler tests
    %results<transpiler> = run-suite("Transpiler Tests", "transpiler/test-transpiler.raku", []);
    
    # Run Interpreter tests
    %results<interpreter> = run-suite("Interpreter Tests", "interpreter/xenober-test.raku", []);
    
    # Print summary
    my $sep = "=" x 60;
    say "\n$sep";
    say "TEST SUMMARY";
    say $sep;
    
    my $passed = 0;
    my $failed = 0;
    
    for %results.kv -> $suite, $status {
        my $icon = $status eq "PASSED" ?? "✅" !! "❌";
        say "$icon $suite: $status";
        $passed++ if $status eq "PASSED";
        $failed++ if $status eq "FAILED";
    }
    
    say $sep;
    say "Total: ✅ $passed passed, ❌ $failed failed";
    
    exit($failed == 0 ?? 0 !! 1);
}
