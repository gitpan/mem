#!/usr/bin/perl -w
## Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl P.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
#
{
	package Math::Simple;
	our $VERSION='0.0.1';
	use warnings;
	use strict;
	use mem;
	our (@ISA, @EXPORT);
	use mem(@EXPORT = qw(logb log2 log10 ), @ISA=qw(Exporter));

	sub logb($$){our @logs; return log($_[1]) / ($logs[$_[0]] ||= log $_[0])}
	sub log2 ($)  { logb(2, $_[0]) }
	sub log10 ($) { logb(10, $_[0]) }
	use Exporter;
	1;
}

package main;
use Math::Simple;

our  $num_tests;
use mem($num_tests=3);

use Test::More tests => $num_tests;

use_ok('mem');

my $a=sprintf "%d", log2(1024);

ok($a==10, "did we import Math::Simple?");

my $b=sprintf "%d", log10 100;

ok($b==2, "did we import the prototypes?");







