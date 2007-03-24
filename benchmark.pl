#! /usr/bin/perl

use strict;
use warnings;

use blib;

use Benchmark qw<cmpthese>;
use File::Find qw<find>;
use Array::Each::Override qw<array_each>;

my %hash;
find({no_chdir => 1, wanted => sub {
    return if !-f;
    open my $fh, '<', $_
        or return;
    while (my $line = <$fh>) {
        $hash{$line}++;
    }
} }, '.');

cmpthese(-10, {
    core => sub { my $n = 0;  while (my ($k, $v) = CORE::each %hash) { $n++ } },
    mine => sub { my $n = 0;  while (my ($k, $v) = array_each %hash) { $n++ } },
});
