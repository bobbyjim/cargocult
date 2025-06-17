use Test;
use lib './lib';

use Xenober16::Interpreter;
use Xenober16::Builder::NodeFactory;

my $tf = Xenober16::Builder::NodeFactory.new;
my $interp = Xenober16::Interpreter.new;

plan 4;

# Create an IdentifierNode and ModuleNode
my $id-node = $tf.new-identifier('test_id');
my $mod-node = $tf.new-module($id-node);

# Interpret the ModuleNode
is $interp.interpret($module-node), Nil, 'Interpret ModuleNode returns Nil';

# Check if we can interpret the IndentifierNode
is $interp.interpret($id-node), Nil, 'Interpret IdentifierNode returns Nil';

# Interpret an unknown node type (should fail/Nil)
my $anon = Any.new;
is $interp.interpret($anon), Nil, 'Interpret unknown node returns Nil (default)';
