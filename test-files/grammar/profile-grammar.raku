#!/usr/bin/env raku
# Grammar Profiler - Profiles parsing performance to identify bottlenecks
# Usage: raku profile-grammar.raku [--verbose] [--only=test-name]

use lib '../lib';
use Xenober16::Grammar;

sub MAIN(Bool :$verbose = False, Str :$only = '') {
    my $common-dir = $*PROGRAM.parent.parent.add('common');
    my @test-files = dir($common-dir).grep({ .f && .extension eq 'xen' }).sort;
    
    if $only {
        @test-files = @test-files.grep(*.basename.contains($only));
    }
    
    say "📊 Grammar Performance Profile";
    say "Timing each test file's parse execution";
    say "=" x 70;
    
    my %total-times;
    my $total-parse-time = 0;
    
    for @test-files -> $test-file {
        my $test-name = $test-file.basename;
        
        my $text = slurp $test-file;
        my $file-size = $text.lines.elems;
        
        # Warm up (first parse might be slower due to JIT)
        my $parser = Xenober16::Grammar.new;
        $parser.parse($text);
        
        # Time the actual parse
        my $start = now;
        my $result = $parser.parse($text);
        my $elapsed = now - $start;
        
        my $ms = ($elapsed * 1000).round(2);
        my $status = $result ?? "✅" !! "❌";
        
        printf "%s %-28s %4d lines  %8.2f ms\n", $status, $test-name, $file-size, $ms;
        
        $total-parse-time += $elapsed;
        %total-times{$test-name} = $ms;
        
        if $verbose {
            say "  Details: {$elapsed.fmt('%.6f')}s ({$ms}ms)";
        }
    }
    
    say "=" x 70;
    
    # Summary statistics
    my @times = %total-times.values.sort;
    my $count = @times.elems;
    my $min = @times[0];
    my $max = @times[*-1];
    my $avg = $total-parse-time / $count;
    
    say "Total parse time: {($total-parse-time * 1000).round(2)} ms ({$total-parse-time.fmt('%.3f')}s)";
    say "Average per file: {($avg * 1000).round(2)} ms";
    say "Min: {$min.fmt('%.2f')} ms";
    say "Max: {$max.fmt('%.2f')} ms";
    say "Files tested: {$count}";
    
    # Find slowest files
    say "\n⏱️  Slowest files (possible bottlenecks):";
    my @slowest = %total-times.sort(-*.value).head(5);
    for @slowest -> (:key($file), :value($time)) {
        my $lines = dir($common-dir).grep(*.basename eq $file)[0].lines.elems;
        my $per-line = $time / $lines;
        printf "  • %-28s %8.2f ms (%6.3f ms/line)\n", $file, $time, $per-line;
    }
}
