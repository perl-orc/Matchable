use Test::Most;

# ABSTRACT: test Util qw( matchable )

use Matchable::Util qw( matchable );

use lib 't/lib';
use T1;

eq_or_diff( matchable( T1->new ), 1, 'T1' );
eq_or_diff( matchable( {} ), undef, 'Hashref' );

done_testing;

