use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Syntax::Highlight::Shell',
    AUTHOR              => 'Sébastien Aperghis-Tramoni <sebastien@aperghis.net>',
    VERSION_FROM        => 'lib/Syntax/Highlight/Shell.pm',
    ABSTRACT_FROM       => 'lib/Syntax/Highlight/Shell.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Shell::Parser' => '0.02',
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Syntax-Highlight-Shell-*' },
);
