use lib 'lib';
use Xenober16::Grammar;

my $source = q:to/EOF/;
MODULE IDENTIFICATION DIVISION.
      MODULE-ID.      DemoModule.
      AUTHOR.         Rob.
      DESCRIPTION.    "Demo".

|o
|o    Testing out the comment stripping
|o    with comments that kinda look like 
|o    tractor-feed paper.
|o

IMPORT DIVISION.
    - MyOtherModule;

MEMORY DIVISION.
    registers: AREA  RAM($02)         SIZE 32;
    hiram:     AREA  BANK(1, $a000)   SIZE 8192;

MACRO DIVISION.
    MAX_COUNTER: INT8 IS 10;
    MIN_COUNTER: INT8 IS 1;

DATA DIVISION.
    counter: int8;

PROCEDURE DIVISION.
    PROC hello( foo: int16 ): uint8;
        SAY foo;
    RETURN 0 END

MAIN DIVISION.
    counter := 1;
    hello(counter);

MODULE END.
EOF

my $raw = $source;
my $clean = strip-comments($raw);
my $ast   = Xenober16::Grammar.parse($clean);

say $ast;

#my $match = Xenober16::Grammar.parse($source)
#orelse say $match;


# if $match {
#     say "🎉 Parse succeeded!";
# } else {
#     my $farthest = $/.pos // 0;  # position where it quit
#     my $context  = $source.substr($farthest, 40).trans("\n" => '⏎');
#     say "💥 Parse failed at position $farthest";
#     say "   Near: «$context»";
# }


sub strip-comments(Str $source) returns Str {
    my @lines = $source.lines;
    my @code;

    for @lines -> $line {
        # If line starts with |o or |* or % skip it
        next if $line ~~ /^('|o' | '|*' | '%')/;

        # Otherwise, keep it
        @code.push($line);
    }

    return @code.join("\n");
}
