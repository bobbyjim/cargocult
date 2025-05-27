use Test;
use lib 'lib';
use Oberon;

plan 2;

my $parsed = Oberon.parse( 'VAR x : INT;');
ok $parsed, 'Parsed a single variable declaration';

$parsed = Oberon.parse( 'VAR x : INT, y : BYTE, z : UINT;');
ok $parsed, 'Parsed multiple variable declarations';

