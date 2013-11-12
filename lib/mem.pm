#!/usr/bin/perl -w
use strict;
#does nothing if run! 

{ package mem;  
  our $VERSION='0.3.3';
  # RCS $Revision: 1.5 $ $Date: 2013-11-07 20:51:28-08 $
	# 0.3.3		- Switch to using ptar for archive creation
	# 0.3.2		- Fix summary to be more descriptive
	#	0.3.1		- Fix Manifest => MANIFEST
	#	0.3.0		- Initial external 'non'-release
  sub import { 
    if (@_ == 1) {
      my ($p, $f, $l)=caller;
      $p =~ s!::!/!g;
      $p .= ".pm";
      $::INC{$p} = $f;
    }
  } 
1
}
###########################################################################
#                 use mem; {{{1

=head1 NAME

mem  -  mark in-"mem" package as already loaded for "use"

=head1 VERSION

Version "0.3.3"

=head1 SYNOPSIS


  use mem;
  use mem(@COMPILE_TIME_DEFINES=qw(a b c));

C<use mem> is a trivial pragma to either allow defining the module it is included from as being defined so that later classes or packages in the same file can C<use> the package to pull in a reference to it, or to be able to call its import routine from a different package in the same file.

With parameter assignments or other actions, it forces those assignments to be
done, immediately, at compile time instead of later at run time.  It can be use, for example, with Exporter, to export typed-sub's among other usages.


=head1 EXAMPLE

Following is a sample program, showing first how it uses both forms
of C<use mem>.



  { package Ar_Type;
    use mem; 
    our (@EXPORT, @ISA);
    use mem(
      @EXPORT=qw(ARRAY), @ISA=qw(Exporter)
    )
    ;
    sub ARRAY (;*) {
      my $p = $_[0]; my $t="ARRAY";
      return @_ ? (ref $p && (1+index($p, $t))) : $t;
    }
  }
  package main;
  use Ar_Type;

  my @a=(1,2,3);
  my $x=\@a;

  P "\\\@a=array" if ARRAY \@a;
  P "x=array" if ARRAY $x;
  P "ref \$x eq ARRAY = %s", ARRAY eq ref $x ? 1:0;

Output:
  \@a=array
  x=array
  ref $x eq ARRAY = 1

Without first C<use mem>, presuming the line was commented out:

  Can't locate Ar_Type.pm in @INC (@INC contains: 
	        /usr/lib/perl5/.../site_perl .) at -e line 12.
  BEGIN failed--compilation aborted at -e line 12.

If we, instead, don't use the 2nd usage (comments before the use and it's closing paren):

  Backslash found where operator expected at -e line 20, near "ARRAY \"
          (Do you need to predeclare ARRAY?)
  Bareword "ARRAY" not allowed while "strict subs" in use at -e line 20.
  syntax error at -e line 20, near "ARRAY \"
  Bareword "ARRAY" not allowed while "strict subs" in use at -e line 22.
  Execution of -e aborted due to compilation errors.


=head1 COMMENTS

The first usage allows 'C<main>' to find C<package Ar_Type>, already in memory
rather than forcing a library search for it.  By default perl doesn't recognize modules already defined in the same file.

The second usage allows the function prototype and definition of 'C<ARRAY>' to
be exported in time for use in 'C<main>'.  Without it, You could still call
C<ARRAY>, but would have to use an ambersand or parens after the subroutine name.
By forcing ISA and EXPORT to be defined before Exporter is called, Exporter can
export the symbols in time for main AND their prototypes.



