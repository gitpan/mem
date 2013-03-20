

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'mem',
    VERSION_FROM => 'lib/mem.pm', # finds \$VERSION
    AUTHOR       => 'Linda Walsh (perl-diddler@tlinx.org)',
    ABSTRACT     => "use in-'mem' version of current package",
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
