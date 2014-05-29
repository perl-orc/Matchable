use Test::Most;

# ABSTRACT: Test Util::equiv

use Matchable::Util qw( ph equiv );

use lib 't/lib';
use T1;

my ( %t1, %t2 );

my $left      = T1->new( val => [ { a => \%t2,         b => ph('foobar'), } ] );
my $right     = T1->new( val => [ { a => ph('bazfoo'), b => \%t1, } ] );
my $composite = T1->new( val => [ { a => \%t2,         b => \%t1 } ] );

my %ph;
my $ret = equiv( $left, $right, \%ph );

eq_or_diff( $ret, $composite, 'placeholders at sublevels on both sides are processed properly' );

eq_or_diff( \%ph, { foobar => \%t1, bazfoo => \%t2 }, 'placeholders at sublevels on both sides are set correctly' );

done_testing;

