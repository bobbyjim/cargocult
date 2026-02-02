#!/usr/bin/env raku
# AST Test Runner - Tests parsing + ASTBuilder semantic validation
# Validates that parse trees correctly transform into well-formed ASTs

use lib '../lib';
use Xenober16::Grammar;
use Xenober16::ASTBuilder;

sub MAIN(Bool :$verbose = False) {
    my $common-dir = $*PROGRAM.parent.parent.add('common');
    my @test-files = dir($common-dir).grep({ .f && .extension eq 'xen' }).sort;
    
    my $passed = 0;
    my $failed = 0;
    my @failures;
    
    say "🧪 AST Builder Test Suite";
    say "Testing parse + ASTBuilder semantic validation";
    say "=" x 60;
    
    for @test-files -> $test-file {
        my $test-name = $test-file.basename;
        print "Testing $test-name ... ";
        
        try {
            my $text = slurp $test-file;
            my $parser = Xenober16::Grammar;
            my $astBuilder = Xenober16::ASTBuilder.new;
            my $result = $parser.parse($text, :actions($astBuilder));
            
            unless $result {
                say "❌ FAILED (parse error)";
                $failed++;
                @failures.push($test-name);
                say "  Grammar failed to parse" if $verbose;
                next;
            }
            
            my $ast = $result.made;
            unless $ast {
                say "❌ FAILED (AST build error)";
                $failed++;
                @failures.push($test-name);
                say "  ASTBuilder did not create AST" if $verbose;
                next;
            }
            
            say "✅ PASSED";
            $passed++;
            
            if $verbose {
                say "  AST root: {$ast.^name}";
            }
            
            CATCH {
                default {
                    say "❌ FAILED (exception)";
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
