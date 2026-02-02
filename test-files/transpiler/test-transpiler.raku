#!/usr/bin/env raku
# Test runner for Xenober16 to Prog8 transpiler
# Usage: raku test-transpiler.raku [--verbose]

use lib '../lib';
use Xenober16::Grammar;
use Xenober16::ASTBuilder;
use Xenober16::Prog8Transpiler;

sub MAIN(Bool :$verbose = False, Bool :$update = False, Str :$only = '') {
    my @test-files = dir('common').grep({ .f && .extension eq 'xen' }).sort;
    
    if $only {
        @test-files = @test-files.grep(*.basename.contains($only));
    }
    
    my $passed = 0;
    my $failed = 0;
    my $skipped = 0;
    
    say "🧪 Running Prog8 transpiler tests...";
    say "=" x 60;
    
    for @test-files -> $test-file {
        my $test-name = $test-file.basename;
        my $expected-file = 'common/expected-p8'.IO.add($test-file.basename.subst('.xen', '.p8'));
        
        print "Testing $test-name ... ";
        
        try {
            # Parse and transpile
            my $text = slurp $test-file;
            my $parser = Xenober16::Grammar;
            my $astBuilder = Xenober16::ASTBuilder.new;
            my $result = $parser.parse($text, :actions($astBuilder));
            
            unless $result {
                say "❌ FAILED (parse error)";
                $failed++;
                next;
            }
            
            my $ast = $result.made;
            unless $ast {
                say "❌ FAILED (AST build error)";
                $failed++;
                next;
            }
            
            my $transpiler = Xenober16::Prog8Transpiler.new;
            my $output = $transpiler.transpile($ast);
            
            # Check if expected output file exists
            if !$expected-file.e {
                if $update {
                    # Create expected output file
                    spurt $expected-file, $output;
                    say "✨ CREATED expected output";
                    $passed++;
                } else {
                    say "⚠️  SKIPPED (no expected output)";
                    say "    Run with --update to create expected output files" if $verbose;
                    $skipped++;
                }
                next;
            }
            
            # Compare with expected output
            my $expected = slurp $expected-file;
            
            if $output eq $expected {
                say "✅ PASSED";
                $passed++;
            } else {
                say "❌ FAILED (output mismatch)";
                $failed++;
                
                if $verbose {
                    say "\n  Expected:";
                    say "  " ~ $expected.lines.map({ "  $_" }).join("\n");
                    say "\n  Got:";
                    say "  " ~ $output.lines.map({ "  $_" }).join("\n");
                    say "";
                }
                
                if $update {
                    spurt $expected-file, $output;
                    say "  ℹ️  Updated expected output file";
                }
            }
            
            CATCH {
                default {
                    say "❌ FAILED (exception: {.message})";
                    say "  {.backtrace}" if $verbose;
                    $failed++;
                }
            }
        }
    }
    
    say "=" x 60;
    say "Results: ✅ $passed passed, ❌ $failed failed, ⚠️  $skipped skipped";
    say "Total: {@test-files.elems} tests";
    
    exit($failed == 0 ?? 0 !! 1);
}
