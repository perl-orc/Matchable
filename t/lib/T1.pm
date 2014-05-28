package T1;

# ABSTRACT: T1 is a class that conforms to what we expect of a matchable

use Moo;

with 'Matchable';

has val                 => ( is      => 'ro', );
has '+_clonable_attrs'  => ( default => sub { ['val'] }, );
has '+_matchable_attrs' => ( default => sub { ['val'] }, );

1;
