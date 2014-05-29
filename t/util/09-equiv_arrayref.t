use Test::Most;

# ABSTRACT: Test Util::equiv_arrayref

use Matchable::Util qw(equiv_arrayref);

use lib 't/lib';
use T1;

eq_or_diff( equiv_arrayref( [ 1, 2, 3 ], [ 1, 2, 3 ] ), [ 1, 2, 3 ], 'integers equate cleanly' );
eq_or_diff( equiv_arrayref( [qw(a b c)], [qw(a b c)] ), [qw(a b c)], 'strings equate cleanly' );
eq_or_diff( equiv_arrayref( {}, [] ), undef, 'when one argument is a hashref, undef (left)' );
eq_or_diff( equiv_arrayref( [], {} ), undef, 'when one argument is a hashref, undef (right)' );
eq_or_diff( equiv_arrayref( [ 1 .. 3 ], [ 4 .. 6 ] ), undef, 'unequivalent ARRAYs are undef' );

my $t1 = T1->new( 'val' => 'foo' );

my $ret = equiv_arrayref( [ $t1, $t1 ], [ $t1, $t1 ] );
eq_or_diff( $ret->[0]->val, 'foo', 'arrays equate cleanly 1' );
eq_or_diff( $ret->[1]->val, 'foo', 'arrays equate cleanly 2' );
$ret->[0]->{'val'} = 'bar';
eq_or_diff( $t1->val, 'foo', 't1s clone cleanly' );

done_testing;

