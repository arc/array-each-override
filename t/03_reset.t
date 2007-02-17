#! /usr/bin/perl

use strict;
use warnings;

use Test::More tests => 14;

use Array::Each::Override;

{
    my @numbers = qw<zero one two three four>;
    my ($i, $val) = each @numbers;
    is($i,   0,      'keys: iterated position 0');
    is($val, 'zero', 'keys: iterated value at position 0');
    is(scalar keys(@numbers), 5, 'keys: key count');
    ($i, $val) = each @numbers;
    is($i,   0,      'keys: iterated position 0 after reset');
    is($val, 'zero', 'keys: iterated value at position 0 after reset');
    ($i, $val) = each @numbers;
    is($i,   1,      'keys: iterated position 1 after reset');
    is($val, 'one',  'keys: iterated value at position 1 after reset');
}

{
    my @numbers = qw<zero one two three four>;
    my ($i, $val) = each @numbers;
    is($i,   0,      'values: iterated position 0');
    is($val, 'zero', 'values: iterated value at position 0');
    is(scalar values(@numbers), 5, 'values: value count');
    ($i, $val) = each @numbers;
    is($i,   0,      'values: iterated position 0 after reset');
    is($val, 'zero', 'values: iterated value at position 0 after reset');
    ($i, $val) = each @numbers;
    is($i,   1,      'values: iterated position 1 after reset');
    is($val, 'one',  'values: iterated value at position 1 after reset');
}
