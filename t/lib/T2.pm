package T2;

# ABSTRACT: T2 is another conformant class
use Safe::Isa;
use Scalar::Util 'blessed';
use Moo;
with 'Matchable';
has value               => ( is      => 'ro', );
has '+_clonable_attrs'  => ( default => sub { ['val'] }, );
has '+_matchable_attrs' => ( default => sub { ['val'] }, );

1;

