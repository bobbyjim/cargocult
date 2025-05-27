use Test;
use lib 'lib';
use CargoCult;

my $code = q{
    var x: ubyte;
    var y: int;
};

plan 2;

{
   my $result = CargoCultGrammar.parse($code, :actions(CargoCultActions));
   my $expected = [
     { name => "x", type => "ubyte" },
     { name => "y", type => "int" }
   ];
   ok $result, "Grammar parses variable declarations";
   #diag $result.perl; # For debugging, make sure it's actually being parsed
   #diag $result.ast.perl;
   is-deeply $result.ast, $expected, "AST matches expected structure";
}
