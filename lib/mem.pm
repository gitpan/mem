#!/usr/bin/perl -w
use strict;
#does nothing if run! 

package mem;  
  our $VERSION='v0.4.0';
	
	our %os2sep = ( Wi => "\x{5c}", MS => "\x{5c}" );

	sub sep_detect() {
		my $OS = substr(($ENV{OS} || $^O),0,2); 
		defined $os2sep{$OS} ? $os2sep{$OS} : '/';
	}

  # RCS $Revision: 1.5 $ $Date: 2013-11-07 20:51:28-08 $
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

Version "0.4.0"

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

=item First, the correct output:

=back

  @a = ref of array
  ref of ed is bee
  ed still points to underlying type, 'array'
  Is ref $light, ARRAY?: yes
  Does ref $ed eq ARRAY?: no
  #  (Because ref "ed" is really a bless "ed" bee)

=over

=item Second, B<I<without>> the first "C<use mem>", presuming the line was commented out:

=back

  Can't locate Ar_Type.pm in @INC (@INC contains: 
    /usr/lib/perl5/5.16.2 ...   /usr/lib/perl5/site_perl .) 
    at /tmp/ex line 18.
  BEGIN failed--compilation aborted at /tmp/ex line 18.  


=over

=item and, Third, instead of dropping the 1st "C<use mem;>", you drop (or comment out) the 2nd usage in the above example, you get:

=back

  Bareword "ARRAY" not allowed while "strict subs" 
    in use at /tmp/ex line 27.
  syntax error at /tmp/ex line 27, near "ARRAY \"
  Bareword "ARRAY" not allowed while "strict subs" 
    in use at /tmp/ex line 30.
  Bareword "ARRAY" not allowed while "strict subs" 
    in use at /tmp/ex line 31.
  Execution of /tmp/ex aborted due to compilation errors. 


=head1 COMMENTS

The first usage allows 'C<main>' to find C<package Ar_Type>, I<already in 
memory>
rather than forcing a library search for it.  By default perl doesn't recognize modules already defined in the same file.

The second usage allows the function prototype and definition of 'C<ARRAY>' to
be exported in time for use in 'C<main>'.  Without it, You could still call
C<ARRAY>, but would have to use an ambersand or parens after the subroutine name.
By forcing ISA and EXPORT to be defined before Exporter is called, Exporter can
export the symbols in time for main AND their prototypes.


=head1 Similar or related function(s):

=over

L<me::inlined>  I<(alpha release )>)

=back

=head4 Note: 


=cut

