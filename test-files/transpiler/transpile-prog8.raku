#!/usr/bin/env raku
# Convenience script for transpiling Xenober16 to Prog8
# Usage: raku transpile-prog8.raku <input.xen> [output.p8]

use lib '../lib';
use Xenober16::Grammar;
use Xenober16::ASTBuilder;
use Xenober16::Prog8Transpiler;

sub MAIN(Str $input-file, Str $output-file?) {
    unless $input-file.IO.e {
        note "Error: Input file '$input-file' does not exist";
        exit 1;
    }
    
    my $parser = Xenober16::Grammar;
    my $astBuilder = Xenober16::ASTBuilder.new;
    my $text = slurp $input-file;
    
    my $result = $parser.parse($text, :actions($astBuilder));
    unless $result {
        note "Error: Failed to parse $input-file";
        exit 1;
    }
    
    my $ast = $result.made;
    unless $ast {
        note "Error: Failed to build AST for $input-file";
        exit 1;
    }
    
    my $transpiler = Xenober16::Prog8Transpiler.new;
    my $output = $transpiler.transpile($ast);
    
    if $output-file {
        spurt $output-file, $output;
        say "✅ Transpiled $input-file to $output-file";
    } else {
        say $output;
    }
}
