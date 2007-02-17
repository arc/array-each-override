package Array::Each::Override;

use strict;
use warnings;

our $VERSION = '0.01';
use base qw<DynaLoader>;

use Scalar::Util qw<reftype>;
use Carp qw<croak>;

__PACKAGE__->bootstrap($VERSION);

*CORE::GLOBAL::each = sub (\[@%]) {
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
};

*CORE::GLOBAL::keys = sub (\[@%]) {
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

*CORE::GLOBAL::values = sub (\[@%]) {
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
};

1;

=head1 NAME

Array::Each::Override - C<each> for iterating over an array's keys and values

=head1 SYNOPSIS

    use Array::Each::Override;

    my @array = get_data();
    while (my ($i, $val) = each @array) {
        print "Position $i contains: $val\n";
    }

=head1 AUTHOR

Aaron Crane E<lt>arc@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2007 Aaron Crane.

This library is free software; you can redistribute it and/or modify it under
the terms of the Artistic License, or (at your option) under the terms of the
GNU General Public License version 2.

=cut
