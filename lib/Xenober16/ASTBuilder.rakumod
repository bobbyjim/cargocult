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
use Xenober16::AST::ForNode;
use Xenober16::AST::CaseNode;
use Xenober16::AST::CallNode;
use Xenober16::AST::BinaryOpNode;
use Xenober16::AST::IdentifierNode;
use Xenober16::AST::NumberNode;
use Xenober16::AST::StringNode;
use Xenober16::AST::RangeNode;
use Xenober16::AST::ReturnNode;
use Xenober16::AST::RecordNode;
use Xenober16::AST::EnumNode;
use Xenober16::AST::MemoryRefNode;
use Xenober16::AST::AreaAccessNode;

# TOP level - builds the complete program AST
method TOP($/) {
my @macros        = $<macro-division> ?? @($<macro-division>.made) !! [];
my @macro-consts  = @macros.grep(Xenober16::AST::ConstDeclNode);
my @macro-procs   = @macros.grep(Xenober16::AST::ProcDeclNode);
my @constants     = $<constants-division> ?? @($<constants-division>.made) !! [];
@constants.append(@macro-consts) if @macro-consts;
my @procedures    = $<procedure-division> ?? @($<procedure-division>.made) !! [];
@procedures.append(@macro-procs) if @macro-procs;
my @data          = $<data-division> ?? @($<data-division>.made) !! [];
my @enums         = $<enum-division> ?? @($<enum-division>.made) !! [];
@data.append(@enums);

make Xenober16::AST::ProgramNode.new(
identification => $<program-identification-division>.made,
imports        => $<import-division> ?? @($<import-division>.made) !! [],
constants      => @constants,
memory         => $<memory-division> ?? @($<memory-division>.made) !! [],
data           => @data,
procedures     => @procedures,
main           => $<main-division> ?? @($<main-division>.made) !! [],
);
}

# IDENTIFICATION DIVISION
method program-identification-division($/) {
    my $module-id = ~$<module-id><identifier>;
    my @params = $<module-parameters> ?? @($<module-parameters>.made) !! ();
    make Xenober16::AST::IdentificationNode.new(
        module-id   => $module-id,
        parameters  => @params,
        author      => $<author> ?? $<author>.made !! Str,
        description => $<description> ?? $<description>.made !! Str,
        purpose     => $<purpose> ?? $<purpose>.made !! Str,
    );
}

method module-id($/) {
    make ~$<identifier>;
}

method module-parameters($/) {
    make $<parameter-decl-list>.made;
}

method parameter-decl($/) {
    make {
        name => ~$<identifier>,
        type => $<type>.made,
        default => $<parameter-init> ?? $<parameter-init>.made !! Nil,
    };
}

method parameter-init($/) {
    make $<expression>.made;
}

method parameter-decl-list($/) {
    my @params = ($<parameter-decl>.made,);
    for $/.list.flat -> $group {
        if $group && $group<parameter-decl> {
            @params.push($group<parameter-decl>.made);
        }
    }
    make @params;
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
} elsif $<range> {
make $<range>.made;
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
    if $<simple-macro> {
        make $<simple-macro>.made;
    } elsif $<meta-macro> {
        make $<meta-macro>.made;
    }
}

method simple-macro($/) {
    make Xenober16::AST::ConstDeclNode.new(
        name => ~$<identifier>,
        value => $<simple-expression>.made,
    );
}

method meta-macro($/) {
    my @params = $<parameter-list> ?? @($<parameter-list>.made) !! [];
    my $return-type = $<type> ?? $<type>.made !! Nil;
    make Xenober16::AST::ProcDeclNode.new(
        name => ~$<identifier>[0],
        parameters => @params,
        return_type => $return-type,
        body => $<statement>».made,
    );
}

method simple-expression($/) {
    if $<range> {
        make $<range>.made;
    } elsif $<string> {
        make $<string>.made;
    } elsif $<qualident> {
        make $<qualident>.made;
    } elsif $<number> {
        make $<number>.made;
    }
}


# DATA DIVISION
method data-division($/) {
    make $<variable-declaration>».made;
}

method enum-division($/) {
    make $<enum-declaration>».made;
}

method data-item($/) {
    if $<variable-declaration> {
        make $<variable-declaration>.made;
    } elsif $<enum-type-definition> {
        make $<enum-type-definition>.made;
    }
}

method enum-type-definition($/) {
    my @members = $<enum-member>».made;
    make Xenober16::AST::EnumNode.new(
        name => ~$<identifier>,
        members => @members,
    );
}

method enum-declaration($/) {
    my @members = $<enum-members>.made;
    make Xenober16::AST::EnumNode.new(
        name => ~$<identifier>,
        members => @members,
    );
}

method enum-members($/) {
    my @members = ($<enum-member>.made,);
    for $/.list.flat -> $group {
        if $group && $group<enum-member> {
            @members.push($group<enum-member>.made);
        }
    }
    make @members;
}

method variable-declaration($/) {
make Xenober16::AST::VarDeclNode.new(
name  => ~$<identifier>,
vtype => $<type>.made,
area  => $<area-annotation> ?? $<area-annotation>.made !! Str,
);
}

method type($/) {
    if $<record-type> {
        make $<record-type>.made;
    } else {
        # Primitive types - just stringify
        make ~$/;
    }
}

method record-type($/) {
    make Xenober16::AST::RecordNode.new(
        fields => $<record-field>».made,
    );
}

method record-field($/) {
    my $field = {
        name => ~$<identifier>,
    };
    
    # Check if this uses @BITFIELD(n) directly or a type with optional bitfield annotation
    if $/[0]<BITFIELD> {
        # Direct @BITFIELD form
        $field<bitfield> = $/[0]<number>.made.value;
        $field<type> = 'bitfield';
    } else {
        # Normal type form
        $field<type> = $/[0]<type>.made // ~($/[0]<type>);
        if $/[0]<bitfield-annotation> {
            $field<bitfield> = $/[0]<bitfield-annotation>.made;
        }
    }
    make $field;
}

method bitfield-annotation($/) {
    make $<number>.made.value;
}

method enum-type($/) {
    my @members = $<enum-member>».made;
    make Xenober16::AST::EnumNode.new(
        name => ~$<identifier>,
        members => @members,
    );
}

method enum-member($/) {
    my $value = $<number> ?? $<number>.made !! Nil;
    make {
        name => ~$<identifier>,
        value => $value,
    };
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
} elsif $<variable-declaration> {
make $<variable-declaration>.made;
} elsif $<if-statement> {
make $<if-statement>.made;
} elsif $<while-loop> {
make $<while-loop>.made;
} elsif $<repeat-loop> {
make $<repeat-loop>.made;
} elsif $<for-loop> {
make $<for-loop>.made;
} elsif $<case-statement> {
make $<case-statement>.made;
} elsif $<procedure-call> {
make $<procedure-call>.made;
} elsif $<return-statement> {
make $<return-statement>.made;
}
}

method return-statement($/) {
    make Xenober16::AST::ReturnNode.new(
        expr => $<expression>.made,
    );
}

method assignment($/) {
    my $target = $<assign-target>.made;
    
    make Xenober16::AST::AssignmentNode.new(
        target     => $target,
        expression => $<expression>.made,
    );
}

method assign-target($/) {
    # Now assign-target is just a designator
    make $<designator>.made;
}

method target-expr($/) {
    my $target = Nil;
    if $<qualident> {
        $target = $<qualident>.made;
    } elsif $<area-access> {
        $target = $<area-access>.made;
    } elsif $<memory-access> {
        $target = $<memory-access>.made;
    }
    make $target;
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

method for-loop($/) {
my $step = $<simple-expression>[2] ?? $<simple-expression>[2].made !! Xenober16::AST::NumberNode.new(value => 1);
make Xenober16::AST::ForNode.new(
variable => ~$<identifier>,
start    => $<simple-expression>[0].made,
end      => $<simple-expression>[1].made,
step     => $step,
body     => @($<statement>».made),
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
} elsif $<designator> {
make $<designator>.made;
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

method arithmetic-expression($/) {
    make $<math-sum>.made;
}

method comparison($/) {
    my @sums = @($<math-sum>».made);
    my @operators = @($<compare-operator>».Str);
    
    if @sums.elems == 1 {
        make @sums[0];
    } else {
        # Build left-associative binary operations
        my $result = @sums[0];
        for 1..^@sums.elems -> $i {
            $result = Xenober16::AST::BinaryOpNode.new(
                op    => @operators[$i - 1],
                left  => $result,
                right => @sums[$i],
            );
        }
        make $result;
    }
}

method math-sum($/) {
    my @products = @($<math-product>».made);
    my @operators = @($<add-operator>».Str);
    
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

method math-product($/) {
    my @factors = @($<factor>».made);
    my @operators = @($<mul-operator>».Str);
    
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
if $<ram-access> {
    make $<ram-access>.made;
} elsif $<bank-access> {
    make $<bank-access>.made;
} elsif $<number> {
    make $<number>.made;
} elsif $<string> {
    make $<string>.made;
} elsif $<designator> {
    make $<designator>.made;
} elsif $<expression> {
    make $<expression>.made;  # Parenthesized expression
}
}

method qualident($/) {
    # Simple qualified identifier (optional module.name)
    my @parts = @($<identifier>);
    my $name = @parts > 1 ?? "{@parts[0]}.{@parts[1]}" !! ~@parts[0];
    
    make Xenober16::AST::IdentifierNode.new(
        name => $name,
        indices => [],
    );
}

method designator($/) {
    # Designator: qualident with optional selectors (array indexing, field access)
    my $node = $<qualident>.made;
    
    # Apply selectors (indices and field accesses)
    my @selectors = @($<selector>);
    for @selectors -> $selector {
        if $selector.ast<indices> {
            # Array index selector
            $node.indices.push: $selector.ast<indices>;
        } elsif $selector.ast<field> {
            # Field access - would need to extend AST node
            # For now, just add to indices (placeholder)
            $node.indices.push: $selector.ast<field>;
        }
    }
    
    make $node;
}

method selector($/) {
    # Selector is either array index or field access
    if $<expression> {
        make { indices => $<expression>.made };
    } elsif $<identifier> {
        make { field => ~$<identifier> };
    }
}

method memory-access($/) {
    if $<ram-access> {
        make $<ram-access>.made;
    } elsif $<bank-access> {
        make $<bank-access>.made;
    }
}

method ram-access($/) {
    my $addr = $<expression>.made;
    make Xenober16::AST::MemoryRefNode.new(:address($addr));
}

method bank-access($/) {
    my $bank = $<expression>[0].made;
    my $addr = $<expression>[1].made;
    make Xenober16::AST::MemoryRefNode.new(:bank($bank), :address($addr));
}

method area-access($/) {
    my $area-name = ~$<identifier>;
    my $index = $<expression>.made;
    make Xenober16::AST::AreaAccessNode.new(:$area-name, :$index);
}

method array-index($/) {
    make $<expression>.made;
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
if $str.starts-with('"') {
    $str = $str.substr(1, $str.chars - 2);
} elsif $str.starts-with("'") {
    $str = $str.substr(1, $str.chars - 2);
}
make Xenober16::AST::StringNode.new(
value => $str,
);
}

method range($/) {
    my $start = $<string>[0] ?? ~$<string>[0] !! $<number>[0].made.value;
    my $end   = $<string>[1] ?? ~$<string>[1] !! $<number>[1].made.value;
    make Xenober16::AST::RangeNode.new(
        start => $start,
        end   => $end,
    );
}

method rest-of-line($/) {
make ~$/;
}
