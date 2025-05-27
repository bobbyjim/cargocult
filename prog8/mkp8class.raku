#!/usr/bin/env raku

# a useful Perlism that isn't built into Raku
sub lcfirst($_) {
    .comb.&{.[0].lc ~ .[1..*].join}
}
    
module Prog8ClassDef {

    # grammar for simple class structure definitions, only slightly nonstandard
    # since it follows Prog8 proper in having significant newlines
    grammar Grammar {
        token ws { \h* }
        token TOP { <class-def-list> <newline>* }
        rule class-def-list { <class-def>+ %% <newline> }
        rule class-def { 'class' <class-name> '{' "\n"* <field-list> "\n"* '}' }
        rule newline { "\n"+ %% <.ws> }
        rule comma { ',' "\n"* %% <.ws> }
        token class-name { <[A..Z]><[A..Za..z0..9_]>* }
        rule field-list { <field-def>* %% "\n" }
        rule field-def { <single-field> | <union> | <enum> }
        rule single-field { <type-name> <array-size>? <field-name> }
        rule union { 'union' <field-name>? '{' "\n"* <field-list> "\n"* '}' }
        rule enum { 'enum' <field-name>? '{' "\n"* <value-list> "\n"* '}' }
        rule value-list { <field-name>+ %% <.comma> }
        token type-name { <builtin-type> | <class-name> }
        rule array-size { '[' <digit> + ']' }
        token digit { <[0..9]> }
        token builtin-type { 'bool' | 'byte' | 'ubyte' | 'word' | 'uword' | 'float' }
        token field-name { <[A..Za..z]> <[A..Za..z0..9_]>* }
    }
    
    # where all the work gets done
    class Actions {
        my %builtins := { bool => 1, byte => 1, float => 5, ubyte => 1, 
                          str  => 2, word => 2, uword => 2 };
        has %.sizes = %builtins.clone;
        has $.float-used is rw = False;
    
        # Blocks to generate Prog8 code to read a value of each type from an
        # address expression
        my %readers := {
            bool  => -> $addr { "@($addr) != 0" },
            byte  => -> $addr { "@($addr) as byte" },
            float => -> $addr { "peekf($addr)" },
            ubyte => -> $addr { "@($addr)" },
            str   => -> $addr { "peekw($addr)" },
            word  => -> $addr { "peekw($addr) as word" },
            uword => -> $addr { "peekw($addr)" }
        };
    
        # Blocks to generate Prog8 code to write a value of each type given
        # (address, value) arguments
        my %writers := {
            bool  => -> $addr, $value { "@($addr) = if $value 1 else 0" },
            byte  => -> $addr, $value { "@($addr) = $value as ubyte" },
            float => -> $addr, $value { "pokef($addr, $value)" },
            ubyte => -> $addr, $value { "@($addr) = $value" },
            str   => -> $addr, $value { "pokew($addr, $value)" },
            word  => -> $addr, $value { "pokew($addr, $value as uword" },
            uword => -> $addr, $value { "pokew($addr, $value)" }
        };
        
        # generate the Prog8 module ${Class}_def.p8
        method class-def($/ is copy) {
            my $class-name = ~$<class-name>;
            my $field-list = $<field-list>.made;
            my $offset = 0;
            my %fields;
            my ($params, $set-all);
            my $var = $class-name.&{ /^<[A..Z]>/ ?? lcfirst($_) !! "the_$_" };

            given open "{$class-name}_def.p8", :w -> $f {
                $f.say: "%import floats\n" if $.float-used;
                $f.say: "%option ignore_unused\n";
                $f.say: "$class-name \{";
                my $enum-type = +@$field-list <= 256  ?? 'ubyte' !! 'uword';

                # handle each member
                for @$field-list -> ($name, $type, $size)  {
                    # enums get turned into constants, optionally
                    # scoped within a sub for namespacing
                    if $type eq 'enum' {
                        if $name {
                            $f.say: "    sub $name\() \{";
                        }
                        my $value = 0;
                        for @$size {
                            $f.print("    ") if $name;
                            $f.say: "    const $enum-type $_ = $value";
                            $value += 1
                        }
                        if $name {
                            $f.say: "    }";
                        }
                        next;
                    }

                    # generate a constant for the offset of this field within
                    # the object body
                    $f.say: "    const uword OFFSET_$name = $offset";
                    %fields{$name} = { :offset($offset), :type($type) };
                    $offset += $size;

                    # by default the getter returns the address of the member,
                    # which is a uword
                    my $rtype = 'uword';

                    if %builtins{$type}:exists  {
                        # if the type is a builtin, though, we return the actual
                        # value instead, and also generate a setter

                        $params ~= ', ' if $params;
                        $params ~= "$type $name";
                        $set-all ~= "\n" if $set-all;
                        $set-all ~= "        set_{$name}($var, $name)";
                        $rtype = $type;

                    } elsif $type ~~ /(\w+) '['/ {
                        # if the member is an array, generate accessors for
                        # individual items. again this defaults to a getter
                        # for the item address, but if the base type is
                        # a builtin we return the actual value and 
                        # provide a setter as well

                        my $base = $0;
                        my $base-size = %.sizes{$base};
                        my $index-type = $size / $base-size < 256 ?? 'ubyte' !! 'uword';
                        my $item-type = %builtins{$base}:exists  ?? $base !! 'uword';

                        $f.say: "    sub get_{$name}_item(uword $var, $index-type index) -> $item-type \{";
                        $f.say: "        uword addr = $var + OFFSET_$name + $base-size * index";

                        if %builtins{$base}:exists {
                            $f.say: "        return {%readers{$base}('addr')}";
                            $f.say: "    }";
                            $f.say: "    sub set_{$name}_item(uword $var, $index-type index, $item-type item) \{";
                            $f.say: "        uword addr = $var + OFFSET_$name + $base-size * index";
                            $f.say: "        {%writers{$base}('addr', 'item')}";
                        } else {
                            $f.say: "        return addr";
                        }
                        $f.say: "    }"
                    }

                    # finally generate the getter
                    $f.say: "    sub get_{$name}(uword $var) -> $rtype \{";
                    if %builtins{$type} {
                        $f.print: qq:to/END/;
            return {%readers{$type}("$var + OFFSET_$name")}
        \}
        sub set_{$name}(uword $var, $type $name) \{
            {%writers{$type}("$var + OFFSET_$name", $name)}
    END
                    }
                    else {
                        $f.say: "        return $var + OFFSET_$name";
                    }
                    $f.say: "    \}\n";
                }
                if $offset {
                    $f.print: qq:to/END/;
        const uword SIZE = $offset
        sub copy(uword source, uword dest) \{
            sys.memcopy(source, dest, SIZE)
        \}
    END
                }
                if $params {
                    $f.say: qq:to/END/;
        sub construct(uword $var, {$params}) \{
    $set-all
        \}
    END
                }
    
                $f.say: "\}";
            }
            my $class-file = "$class-name.p8";
            if ! $class-file.IO.e {
                given open $class-file, :w -> $f {
                    $f.say: "%import {$class-name}_def\n";
                    $f.say: "$class-name \{";
                    $f.say: "    %option merge";
                    $f.say: "}";
                }
            }
            %.sizes{$class-name} = $offset;
        }

        # handle union types
        method union($/) {
            my @fields := $<field-list>.made;
            my $size = @fields»[2].max;
            my $result = gather for @fields -> ($name, $type, $size) {
                take [$name, $type, 0];
            }.Array;
            if $<field-name> {
                $result.push([~$<field-name>, 'union', $size]);
            }
            make $result;
        }

        method array-size($/) {
            make +$<digit>.map(~*).join
        }

        method single-field($/) {
            my $name = ~$<field-name>;
            my $type = ~$<type-name>;
            $.float-used = True if $type eq 'float';
            die "Unknown type '$type'\n" unless %.sizes{$type}:exists;
    
            my $size = %.sizes{$type};
            if $<array-size> {
                $type ~= "[{$<array-size>.made}]";
                $size *= $<array-size>.made;
            }
    
            my $result = ($name, $type, $size);
            make $result;
        }
    
        method field-def($/) {
            my $result;
            if $<union> {
                $result = $<union>.made;
            } elsif $<enum> {
                $result = $<enum>.made;
            } else {
                $result = [ $<single-field>.made, ]
            }
            make $result;
        }

        method field-list($/) {
            my $result = $<field-def>».made.map(|*).Array;
            make $result;
        }

        method enum($/) {
            make [[ $<field-name>, 'enum', $<value-list>.made ],]
        }
        method value-list($/) {
            make $<field-name>.map: ~*
        }
    }
}

# main!
sub MAIN($class-name is copy, $input-file is copy = (Any)) { 

    if !$input-file {
        if $class-name ~~ /^(<-[.]>+)\./ {
            $input-file = $class-name;
            $class-name = $0;
        } else {
            $input-file = "$class-name.def";
        }
    }

    die "Unable to read '$input-file'\n" unless my $source = $input-file.IO.slurp;

    # very low-rent import functionality
    while $source ~~ / '%import' / {
        $source ~~ s:g/^ \h* '%import' \h+ (<[A..Z]><[A..Za..z0..9_]>*) \h* \n/{"$0.def".IO.slurp}/;
    }

    Prog8ClassDef::Grammar.parse($source, actions => Prog8ClassDef::Actions.new);
}
