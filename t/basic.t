use lib 'lib';
use Test;
use CargoCult;

my $code = q{
    var x: uint8;
    var y: int16;
};

plan 2;

{
   my $result = CargoCultGrammar.parse($code, :actions(CargoCultActions));
   my $expected = [
     { name => "x", type => "uint8" },
     { name => "y", type => "int16" }
   ];
   ok $result, "Grammar parses variable declarations";
   #diag $result.perl; # For debugging, make sure it's actually being parsed
   #diag $result.ast.perl;
   is-deeply $result.ast, $expected, "AST matches expected structure";
}
