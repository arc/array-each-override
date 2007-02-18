package Array::Each::Override;

use strict;
use warnings;

our $VERSION = '0.01';
use base qw<DynaLoader>;

use Scalar::Util qw<reftype>;
use Carp qw<croak>;

my @FUNCTIONS = qw<each keys values>;
my %SIMPLE_FUNCTION = map { $_ => 1 } @FUNCTIONS;
my  %KNOWN_FUNCTION = map { ($_ => 1, "array_$_" => 1) } @FUNCTIONS;

__PACKAGE__->bootstrap($VERSION);

sub import {
    my ($class, @imports) = @_;
    my $caller = caller;
    for my $export (_parse_import_list($caller, @imports)) {
        my ($dest, $name, $func) = @$export{qw<dest name func>};
        no strict qw<refs>;
        *{"$dest\::$name"} = $func;
    }
}

sub unimport {
    my ($package, @imports) = @_;
    my $caller = caller;
    for my $export (_parse_import_list($caller, @imports)) {
        my ($dest, $name, $func) = @$export{qw<dest name func>};
        no strict qw<refs>;
        delete ${"$dest\::"}{$name}
    }
}

sub _parse_import_list {
    my ($importer, @imports) = @_;

    my %imports;
    my $target = 'local';
    my @pending;

    for my $arg (@imports) {
        if ($arg eq ':local' || $arg eq ':global') {
            if (@pending) {
                push @{ $imports{ $target || 'local' } }, @pending;
                ($target, @pending) = ();
            }
            ($target = $arg) =~ s/\A ://xms;
        }
        elsif ($KNOWN_FUNCTION{$arg}) {
            croak "Impossible to use a :global version of $arg"
                if !$SIMPLE_FUNCTION{$arg};
            push @pending, $arg;
        }
        else {
            croak "Invalid argument '$arg' in import list; should be ",
                ":local, :global, or the name of an exported function";
        }
    }

    if ($target) {
        @pending = @FUNCTIONS
            if !@pending;
        push @{ $imports{$target} }, @pending;
    }

    for my $how (keys %imports) {
        my $dest = $how eq 'local' ? $importer : 'CORE::GLOBAL';
        my %seen;
        for my $name (@{ $imports{$how} }) {
            next if $seen{$name}++;
            my $local_name = $SIMPLE_FUNCTION{$name} ? "array_$name" : $name;
            push @imports, {
                dest => $dest,
                name => $name,
                func => do { no strict 'refs'; \&$local_name },
            };
        }
    }

    return @imports;
}

sub array_each (\[@%]) {
    my ($arg) = @_;
    my $type = reftype $arg;
    if ($type eq 'HASH') {
        return CORE::each %$arg;
    }
    elsif ($type eq 'ARRAY') {
        my $index = _advance_iterator($arg);
        if ($index >= @$arg) {
            _clear_iterator($arg);
            return;
        }
        return wantarray ? ($index, $arg->[$index]) : $index;
    }
    else {
        croak "Type of argument to each must be hash or array (not $type)";
    }
}

sub array_keys (\[@%]) {
    my ($arg) = @_;
    my $type = reftype $arg;
    if ($type eq 'HASH') {
        return CORE::keys %$arg;
    }
    elsif ($type eq 'ARRAY') {
        _clear_iterator($arg);
        return wantarray ? (0 .. $#$arg) : @$arg;
    }
    else {
        croak "Type of argument to keys must be hash or array (not $type)";
    }
};

sub array_values (\[@%]) {
    my ($arg) = @_;
    my $type = reftype $arg;
    if ($type eq 'HASH') {
        return CORE::values %$arg;
    }
    elsif ($type eq 'ARRAY') {
        _clear_iterator($arg);
        return @$arg;
    }
    else {
        croak "Type of argument to values must be hash or array (not $type)";
    }
}

1;

=head1 NAME

Array::Each::Override - C<each> for iterating over an array's keys and values

=head1 SYNOPSIS

    use Array::Each::Override;

    my @array = get_data();
    while (my ($i, $val) = each @array) {
        print "Position $i contains: $val\n";
    }

=head1 DESCRIPTION

This module provides new implementations of three core functions: C<each>,
C<values>, and C<keys>.

=over 4

=item C<each>

The core C<each> function iterates over a hash; each time it's called, it
returns a 2-element list of a key and value in the hash.  The new version of
C<each> does not change the behaviour of C<each> when called on a hash.
However, it also allows you to call C<each> on array.  Each time it's called,
it returns a 2-element list of the next uniterated index in the the array, and
the value at that index.

When the array is entirely iterated, an empty list is returned in list context.
The next call to array C<each> after that will start iterating again.

=item C<keys>

The core C<keys> function returns a list of the keys in a hash, or a count of
the keys in a hash when called in scalar context.  The new version of C<keys>
does not change the behaviour of C<keys> when called on a hash.  However, it
also allows you to call C<keys> on an array.

In list context, C<keys @array> returns a list of the indexes in the array; in
scalar context, it returns the number of elements in the array.

=item C<values>

The core C<values> function returns a list of the values in a hash, or a count
of the values in a hash when called in scalar context.  The new version of
C<values> does not change the behaviour of C<values> when called on a hash.
However, it also allows you to call C<values> on an array.

In list context, C<values @array> returns a list of the elements in the array;
in scalar context, it returns the number of elements in the array.

=back

There is a single iterator for each array, shared by all C<each>, C<keys>, and
C<values> calls in the program.  It can be reset by reading all the elements
from the iterator with C<each>, or by evaluating C<keys @array> or C<values
@array>.

=head1 ALTERNATIVE NAMES

You may prefer not to change the core C<each>, C<keys>, and C<values>
functions.  If so, you can import the new functions under alternative,
noninvasive names:

    use Array::Each::Override qw<array_each array_keys array_values>;

The functions with these noninvasive names behave exactly the same as the
overridden core functions.

You might alternatively prefer to make the new functions available to all parts
of your program in one fell swoop:

    use Array::Each::Override qw<:global>;

You can even combine these.  Any of the following calls will make C<each>
available globally, C<keys> available in just the current package, and
C<values> available in the current package under the name C<array_values>:

    use Array::Each::Override qw<keys array_values :global each>;
    use Array::Each::Override qw<:global each :local array_values keys>;

You can also unimport names:

    no Array::Each::Override qw<:global>;

=head1 BUGS

If you set C<$[> to anything other than 0, then (a) please stop doing that,
because it's been deprecated for a long time, and (b) C<each>, C<keys>, and
C<values> on arrays probably don't do what you expect.

Importing and unimporting function names has an effect on your entire package,
not just your lexical scope.

=head1 SEE ALSO

L<perlfunc|each>

=head1 AUTHOR

Aaron Crane E<lt>arc@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2007 Aaron Crane.

This library is free software; you can redistribute it and/or modify it under
the terms of the Artistic License, or (at your option) under the terms of the
GNU General Public License version 2.

=cut
