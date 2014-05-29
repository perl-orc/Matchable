use Test::Most;

# ABSTRACT: Test Util::equiv_matchable

use Matchable::Util qw( equiv_matchable );
use lib 't/lib';
use T1;

my $t1 = T1->new( val => 'foo' );

eq_or_diff( equiv_matchable( $t1, $t1 )->val, 'foo', 'matchables are cloned correctly' );

done_testing;

