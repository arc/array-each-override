use ExtUtils::MakeMaker;
my $module_file = 'lib/Array/Each/Override.pm';
WriteMakefile(
    NAME          => 'Array::Each::Override',
    AUTHOR        => 'Aaron Crane <arc@cpan.org>',
    ABSTRACT_FROM => $module_file,
    VERSION_FROM  => $module_file,
    OBJECT        => 'Override.o',
    PREREQ_PM     => {
        Scalar::Util => 0,
    },
);
