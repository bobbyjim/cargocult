unit class Xenober16::ASTBuilder;

# Import all AST node classes
use Xenober16::AST::ASTNode;
use Xenober16::AST::ProgramNode;
use Xenober16::AST::IdentificationNode;
use Xenober16::AST::ImportNode;
use Xenober16::AST::ConstDeclNode;
use Xenober16::AST::MemoryAreaNode;
use Xenober16::AST::VarDeclNode;
use Xenober16::AST::ParamDeclNode;
use Xenober16::AST::ProcDeclNode;
use Xenober16::AST::AssignmentNode;
use Xenober16::AST::SayNode;
use Xenober16::AST::EchoNode;
use Xenober16::AST::IfNode;
use Xenober16::AST::WhileNode;
use Xenober16::AST::RepeatNode;
use Xenober16::AST::CaseNode;
use Xenober16::AST::CallNode;
use Xenober16::AST::BinaryOpNode;
use Xenober16::AST::IdentifierNode;
use Xenober16::AST::NumberNode;
use Xenober16::AST::StringNode;
use Xenober16::AST::RangeNode;

# TOP level - builds the complete program AST
method TOP($/) {
make Xenober16::AST::ProgramNode.new(
identification => $<program-identification-division>.made,
imports        => $<import-division> ?? @($<import-division>.made) !! [],
constants      => $<constants-division> ?? @($<constants-division>.made) !! [],
memory         => $<memory-division> ?? @($<memory-division>.made) !! [],
data           => $<data-division> ?? @($<data-division>.made) !! [],
procedures     => $<procedure-division> ?? @($<procedure-division>.made) !! [],
main           => $<main-division> ?? @($<main-division>.made) !! [],
);
}

# IDENTIFICATION DIVISION
method program-identification-division($/) {
make Xenober16::AST::IdentificationNode.new(
module-id   => $<module-id>.made,
author      => $<author> ?? $<author>.made !! Str,
description => $<description> ?? $<description>.made !! Str,
purpose     => $<purpose> ?? $<purpose>.made !! Str,
);
}

method module-id($/) {
make ~$<identifier>;
}

method author($/) {
make ~$<identifier>;
}

method description($/) {
make ~$<rest-of-line>;
}

method purpose($/) {
make ~$<rest-of-line>;
}

# IMPORT DIVISION
method import-division($/) {
make $<use>».made;
}

method use($/) {
make Xenober16::AST::ImportNode.new(
module => ~$<identifier>,
);
}

# CONSTANTS DIVISION
method constants-division($/) {
make $<constant-declaration>».made;
}

method constant-declaration($/) {
make Xenober16::AST::ConstDeclNode.new(
name  => ~$<identifier>,
vtype => ~$<type>,
value => $<constant-value>.made,
);
}

method constant-value($/) {
if $<number> {
make $<number>.made;
} elsif $<string> {
make $<string>.made;
}
}

# MEMORY DIVISION
method memory-division($/) {
make $<area>».made;
}

method area($/) {
# The alternation ( <ram-area> | <bank-area> ) creates a positional capture at [0]
my $area-type = $/[0]<ram-area> ?? 'RAM' !! 'BANK';
my $area-data = $/[0]<ram-area> ?? $/[0]<ram-area>.made !! $/[0]<bank-area>.made;

if $area-type eq 'RAM' {
make Xenober16::AST::MemoryAreaNode.new(
name      => ~$<identifier>,
area-type => 'RAM',
address   => $area-data<address>,
size      => $<number>.made.value,
);
} else {
make Xenober16::AST::MemoryAreaNode.new(
name         => ~$<identifier>,
area-type    => 'BANK',
bank         => $area-data<bank>,
bank-address => $area-data<address>,
size         => $<number>.made.value,
);
}
}

method ram-area($/) {
make {
address => $<number>.made.value,
};
}

method bank-area($/) {
# Grammar has two <number> captures, accessible as an array
my @number-nodes = @($<number>)».made;
make {
bank    => @number-nodes[0].value,
address => @number-nodes[1].value,
};
}

# MACRO DIVISION (not yet fully implemented)
method macro-division($/) {
make $<macro-declaration>».made;
}

method macro-declaration($/) {
# TODO: Create MacroNode when needed
make {
type       => 'Macro',
name       => ~$<identifier>,
macro-type => ~$<macro-type>,
value      => $<simple-expression>.made,
};
}

# DATA DIVISION
method data-division($/) {
make $<variable-declaration>».made;
}

method variable-declaration($/) {
make Xenober16::AST::VarDeclNode.new(
name  => ~$<identifier>,
vtype => ~$<type>,
area  => $<area-annotation> ?? $<area-annotation>.made !! Str,
);
}

method area-annotation($/) {
make ~$<identifier>;
}

# PROCEDURE DIVISION
method procedure-division($/) {
make $<procedure>».made;
}

method procedure($/) {
make Xenober16::AST::ProcDeclNode.new(
name       => ~$<identifier>,
parameters => $<parameter-list> ?? $<parameter-list>.made !! [],
body       => @($<statement>».made),
);
}

method parameter-list($/) {
# Grammar: <parameter> ( <COMMA> <parameter> )*
# First parameter is direct capture, additional ones are in repetition groups
my @params = ($<parameter>.made,);
for $/.list.flat -> $group {
if $group && $group<parameter> {
@params.push($group<parameter>.made);
}
}
make @params;
}

method parameter($/) {
make Xenober16::AST::ParamDeclNode.new(
name  => ~$<identifier>,
ptype => ~$<type>,
);
}

# MAIN DIVISION
method main-division($/) {
make $<statement>».made;
}

# STATEMENTS
method statement($/) {
if $<assignment> {
make $<assignment>.made;
} elsif $<say> {
make $<say>.made;
} elsif $<echo> {
make $<echo>.made;
} elsif $<if-statement> {
make $<if-statement>.made;
} elsif $<while-loop> {
make $<while-loop>.made;
} elsif $<repeat-loop> {
make $<repeat-loop>.made;
} elsif $<case-statement> {
make $<case-statement>.made;
} elsif $<procedure-call> {
make $<procedure-call>.made;
}
}

method assignment($/) {
make Xenober16::AST::AssignmentNode.new(
target     => $<qualident>.made,
expression => $<expression>.made,
);
}

method say($/) {
make Xenober16::AST::SayNode.new(
expression => $<simple-expression>.made,
);
}

method echo($/) {
make Xenober16::AST::EchoNode.new(
expression => $<simple-expression>.made,
);
}

method if-statement($/) {
# Get the main IF condition
my $condition = $<expression>.made;

# Get the main THEN branch statements
my @then-statements = @($<statement>».made);

# Build elsif branches from repetition groups
my @elsif-branches = [];
for $/.list.flat -> $group {
if $group && $group<ELSIF> {
my $elsif-expr = $group<expression>.made;
my @elsif-stmts = @($group<statement>».made);
@elsif-branches.push({
condition => $elsif-expr,
body => @elsif-stmts,
});
}
}

# Get else branch from repetition groups
my @else-statements = [];
for $/.list.flat -> $group {
if $group && $group<ELSE> {
@else-statements = @($group<statement>».made);
last;
}
}

make Xenober16::AST::IfNode.new(
condition      => $condition,
then-branch    => @then-statements,
elsif-branches => @elsif-branches,
else-branch    => @else-statements,
);
}

method while-loop($/) {
make Xenober16::AST::WhileNode.new(
condition => $<expression>.made,
body      => @($<statement>».made),
);
}

method repeat-loop($/) {
make Xenober16::AST::RepeatNode.new(
body      => @($<statement>».made),
condition => $<expression>.made,
);
}

method case-statement($/) {
# Build case branches (as hashes since they mix selectors and statements)
my @branches = [];
for @($<case-when>».made) -> $when {
@branches.push({
selectors => @($when<selectors>),
body      => @($when<statements>),
});
}

make Xenober16::AST::CaseNode.new(
selector    => $<comparison>.made,
branches    => @branches,
else-branch => $<statement> ?? @($<statement>».made) !! [],
);
}

method case-when($/) {
make {
selectors  => $<case-selector>».made,
statements => $<statement>».made,
};
}

method case-selector($/) {
if $<range> {
make $<range>.made;
} elsif $<number> {
make $<number>.made;
} elsif $<qualident> {
make $<qualident>.made;
}
}

method procedure-call($/) {
make Xenober16::AST::CallNode.new(
name      => ~$<identifier>,
arguments => $<argument-list> ?? $<argument-list>.made !! [],
);
}

method argument-list($/) {
# Grammar: <expression> ( <COMMA> <expression> )*
# First expression is direct capture, additional ones are in repetition groups
my @exprs = ($<expression>.made,);
for $/.list.flat -> $group {
if $group && $group<expression> {
@exprs.push($group<expression>.made);
}
}
make @exprs;
}

# EXPRESSIONS
method expression($/) {
if $<string> {
make $<string>.made;
} elsif $<comparison> {
make $<comparison>.made;
}
}

method comparison($/) {
# First sum is direct capture
my @sums = ($<sum>.made,);
my @operators = ();

# Additional sums and operators are in the repetition groups
# Each repetition group is wrapped in an array, so we flatten
for $/.list.flat -> $group {
if $group && $group<sum> {
# Extract operator - may be 1 or 2 characters (<=, >=, <>, or single char)
my $str = $group.Str.trim;
my $op;
if $str.starts-with('<=') || $str.starts-with('>=') || $str.starts-with('<>') {
$op = $str.substr(0, 2);
} else {
$op = $str.substr(0, 1);
}
@operators.push($op);
@sums.push($group<sum>.made);
}
}

if @sums.elems == 1 {
make @sums[0];
} else {
# Has comparison operators
make Xenober16::AST::BinaryOpNode.new(
op    => @operators[0],
left  => @sums[0],
right => @sums[1],
);
}
}

method sum($/) {
# First product is direct capture
my @products = ($<product>.made,);
my @operators = ();

# Additional products and operators are in the repetition groups
# Each repetition group is wrapped in an array, so we flatten
for $/.list.flat -> $group {
if $group && $group<product> {
# Extract operator - first non-whitespace character
my $str = $group.Str.trim;
my $op = $str.substr(0, 1);  # First character is the operator
@operators.push($op);
@products.push($group<product>.made);
}
}

if @products.elems == 1 {
make @products[0];
} else {
# Build left-associative binary operations
my $result = @products[0];
for 1..^@products.elems -> $i {
$result = Xenober16::AST::BinaryOpNode.new(
op    => @operators[$i - 1],
left  => $result,
right => @products[$i],
);
}
make $result;
}
}

method product($/) {
# First factor is direct capture
my @factors = ($<factor>.made,);
my @operators = ();

# Additional factors and operators are in the repetition groups
# Each repetition group is wrapped in an array, so we flatten
for $/.list.flat -> $group {
if $group && $group<factor> {
# Extract operator - first non-whitespace character
my $str = $group.Str.trim;
my $op = $str.substr(0, 1);  # First character is the operator
@operators.push($op);
@factors.push($group<factor>.made);
}
}

if @factors.elems == 1 {
make @factors[0];
} else {
# Build left-associative binary operations
my $result = @factors[0];
for 1..^@factors.elems -> $i {
$result = Xenober16::AST::BinaryOpNode.new(
op    => @operators[$i - 1],
left  => $result,
right => @factors[$i],
);
}
make $result;
}
}

method factor($/) {
if $<number> {
make $<number>.made;
} elsif $<string> {
make $<string>.made;
} elsif $<qualident> {
make $<qualident>.made;
} elsif $<expression> {
make $<expression>.made;  # Parenthesized expression
}
}

method simple-expression($/) {
if $<string> {
make $<string>.made;
} elsif $<qualident> {
make $<qualident>.made;
} elsif $<number> {
make $<number>.made;
}
}

method qualident($/) {
make Xenober16::AST::IdentifierNode.new(
name => ~$<identifier>,
);
}

method identifier($/) {
make ~$/;
}

# LITERALS
method number($/) {
if $<hex-number> {
make $<hex-number>.made;
} elsif $<dec-number> {
make $<dec-number>.made;
}
}

method hex-number($/) {
# Remove the leading '$' and get the hex digits
my $hex-str = (~$/).subst(/^\$/, '');
make Xenober16::AST::NumberNode.new(
value => :16($hex-str),
radix => 16,
);
}

method dec-number($/) {
make Xenober16::AST::NumberNode.new(
value => +~$/,
radix => 10,
);
}

method string($/) {
# Remove quotes from the string
my Str $str = ~$/;
$str .= subst(/^\"/, '');
$str .= subst(/\"$/, '');
make Xenober16::AST::StringNode.new(
value => $str,
);
}

method range($/) {
my @numbers = $<number>».made;
make Xenober16::AST::RangeNode.new(
start => @numbers[0].value,
end   => @numbers[1].value,
);
}

method rest-of-line($/) {
make ~$/;
}
