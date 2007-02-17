package Array::Each::Override;

use strict;
use warnings;

our $VERSION = '0.01';

use Scalar::Util qw<reftype weaken>;

# XXX: this hash gets too big if you don't exhaust your iterators, but is
# enough for a proof-of-concept.  The real implementation should use a piece of
# magic on the iterated array, so that the iterator data gets automatically
# thrown away when the array is collected.  That also avoids weak references,
# which can't be as efficient as normal references.
my %ITERATOR_FOR;

*CORE::GLOBAL::each = sub (\[@%]) {
    my ($arg) = @_;
    if (reftype $arg eq 'HASH') {
        return CORE::each %$arg;
    }
    else {
        my $iterator = $ITERATOR_FOR{$arg} ||= do {
            my $it = [0, $arg];
            weaken $it->[1];
            $it;
        };
        my ($next, $ref) = @$iterator;
        if (!$ref || $next >= @$ref) {
            delete $ITERATOR_FOR{$arg};
            return;
        }
        my $curr = $iterator->[0]++;
        return wantarray ? ($curr, $arg->[$curr]) : $curr;
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
