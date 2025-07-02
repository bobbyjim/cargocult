unit module Xenober16::Builder::Registry;

sub registry {
    state %registry;
    return %registry;
}

sub register(Str $name, Mu $class) is export {
    die "Node name must be defined"  unless $name.defined;
    die "Node class must be defined" unless $class.defined;
    if registry(){$name}:exists {
        die "Node type '$name' is already registered.";
    }
    say "✅ Registered node type '$name' with class " ~ $class.^name if $*VERBOSE;
    registry(){$name} = $class;
}

sub get(Str $name) is export {
    registry(){$name} // die "❌ Unknown node type: '$name'";
}

our @EXPORT-OK := <register get>; # 👈 This enables :register and :get tags
our @EXPORT-ALL := <register get>;
