#!/usr/bin/perl -w
use strict;
#does nothing if run! 
#

package mem;  
  our $VERSION='0.4.5';
	
	our %os2sep = ( Wi => "\x{5c}", MS => "\x{5c}" );

	sub sep_detect() {
#		my $OS = substr(($ENV{OS} || $^O),0,2); 
#		defined $os2sep{$OS} ? $os2sep{$OS} : 
		'/';
	}

  # RCS $Revision: 1.7 $ $Date: 2013-12-16 13:21:47-08 $
	# 0.4.5		- Add alt version format for ExtMM 
	# 0.4.4		- Add dep on recent ExtMM @ in BUILD_REQ
	#           Documentation enhancements and clarifications.
	# 0.4.3		- change format of VERSION to a string (vec unsupported
	# 					in earlier perl versions)
	# 0.4.2		- doc change & excisement of  a symlink (maybe winprob)
	# 0.4.1		- revert attempt to use win32 BS -- seems to cause
	# 					more problems than it fixed.
	# 0.4.0		- Documentation upgrade; 
  #           Attempt to point to win32 paths w/backslash
	# 0.3.3		- Switch to using ptar for archive creation
	# 0.3.2		- Fix summary to be more descriptive
	#	0.3.1		- Fix Manifest => MANIFEST
	#	0.3.0		- Initial external 'non'-release

	our $sep;

  sub import { 
    if (@_ >= 1) {
      my ($p, $f, $l)=caller;
		  $sep ||= sep_detect();
      if (@_ >= 1) { 
        $p="main" unless $p;
        $p =~ s!::!$sep!ge;
        $p .= ".pm";
        $::INC{$p} = $f."#".$l unless exists $::INC{$p};
      }
    }
  } 
1;


##########################################################################
#                 use mem; {{{1

=pod

=head1 NAME

=over

=item 

mem  -  use "in-mem" pkgs & force definitions into mem early

=back

=head1 VERSION

=over 

Version "0.4.5"

=back

=head1 SYNOPSIS


  use mem;
  use mem(@COMPILE_TIME_DEFINES=qw(a b c));

B<C<mem>> is a trivial pragma to either allow defining the module it is included from as being defined so that later classes or packages in the same file can C<use> the package to pull in a reference to it, or to be able to call its import routine from a different package in the same file.

With parameter assignments or other actions, it forces those assignments to be
done, immediately, at compile time instead of later at run time.  It can be use, for example, with Exporter, to export typed-sub's among other usages.


=head1 EXAMPLE

Following, is a sample program, showing two uses of C<mem>.

  use strict; use warnings;

  { package Ar_Type;
      #
      use mem;                                    #1st usage 
      our (@EXPORT, @ISA);
      sub ARRAY (;*) {
          my $p = $_[0]; my $t="ARRAY";
          return @_ ? (ref $p && (1+index($p, $t))) : $t;
      }
      #
      use mem(                                    #2nd usage 
          @EXPORT=qw(ARRAY), @ISA=qw(Exporter)
      #
      )                                           #(also) 2nd usage 
      ;
      use Exporter;
  }

  package main;
  use Ar_Type;
  use P;
	use Types::Core

  my @a=(1,2,3);
  my ($ed, $light);
      (@$ed, @$light) = (@a, @a);  #ed & light point to copies of @a
  bless $ed, "bee";

  P "\@a = ref of array" if ARRAY \@a;
  P "ref of ed is %s", ref $ed;
  P "ed still points to underlying type, 'array'" if ARRAY $ed;
  P "Is ref \$light, ARRAY?: %s", (ref $light eq ARRAY) ? 'yes':'no';
  P "Does \"ref \$ed\" eq ARRAY?: %s", (ref $ed eq ARRAY) ? 'yes':'no';
  P "%s", "#  (Because \"ref \$ed\" is really a bless \"ed\" bee)"

=over

=item 

First, the correct output:

  @a = ref of array
  ref of ed is bee
  ed still points to underlying type, 'array'
  Is ref $light, ARRAY?: yes
  Does ref $ed eq ARRAY?: no
  #  (Because ref "ed" is really a bless "ed" bee)


=item 

Second, B<I<without>> the first "C< use mem >", presuming the line was commented out:

  Can't locate Ar_Type.pm in @INC (@INC contains: 
    /usr/lib/perl5/5.16.2 ...   /usr/lib/perl5/site_perl .) 
    at /tmp/ex line 18.
  BEGIN failed--compilation aborted at /tmp/ex line 18.  

This is due to C<package AR_Type>, the package already declared
and in I<C<mem>ory>>, being I<ignored> by Perl's C<use> statement
because some I<Perl-specific>, I<"internal flag"> is not set for
C<package Ar_Type>.  The first C<use mem> causes this flag, normally
set with the path of the of a C<use>d file, to be set with the
containing file path and an added comment, containing the line number.

This tells perl to use the definition of the package that is already
in C<mem>ory.

=over

I<and>

=back

=item 

Third, instead of dropping the 1st "C< use mem >", you drop (or comment out) the 2nd usage in the above example, you get:

  Bareword "ARRAY" not allowed while "strict subs" 
    in use at /tmp/ex line 27.
  syntax error at /tmp/ex line 27, near "ARRAY \"
  Bareword "ARRAY" not allowed while "strict subs" 
    in use at /tmp/ex line 30.
  Bareword "ARRAY" not allowed while "strict subs" 
    in use at /tmp/ex line 31.
  Execution of /tmp/ex aborted due to compilation errors. 


This happens because when C<use Exporter> is called, the 
contents of C<@EXPORT> is not known.  Even with the assignment
to C<@EXPORT>, the "C<@EXPORT=qw(ARRAY)>" being right above
the C<use Exporter> statement.  Similarly to the first error, above,
Perl doesn't use the value of C<@EXPORT> just above it.  Having
C< use mem > in the second position forces Perl to put the assignment
to @EXPORT in C< mem >ory, so that when C< use Exporter > is called, 
it can pick up the name of C<ARRAY> as already being "exported" and
B<defined>.  

Without C<use mem> putting the value of C<@EXPORT> in C<mem>ory, 
C<ARRAY> isn't defined, an you get the errors shown above.

=back

=head2 Summary

The first usage allows 'C<main>' to find C<package Ar_Type>, I<already in 
C<mem>ory>.

The second usage forces the definition of 'C<ARRAY>' into C<mem>ory so
they can be exported by an exporter function.

In B<both> cases, C<mem> allows your already-in-C<mem>ory code to 
be used.  Thsi allows simplified programming and usage without knowledge
of or references to Perl's internal-flags or internal run phases.

=head1 SEE ALSO


See L<Exporter> for information on exporting names.  See the newer, 
L<Xporter> for doing similar without the need for setting C<@ISA>
and persistent defaults in C<@EXPORT>. See L<P> for more details about 
the generic print verb and see L<Types::Core> for a more complete
treatment of the CORE Types.



=cut

