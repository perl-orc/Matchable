use Test::Most;

# ABSTRACT: Test Util::equiv_simple

use Matchable::Util qw(equiv_simple);

eq_or_diff( equiv_simple( 'foo', 'foo' ), 'foo', 'matching strings' );
eq_or_diff( equiv_simple( 'foo', 'bar' ), undef, 'unmatching strings' );
eq_or_diff( equiv_simple( 123,   123 ),   123,   'matching numbers' );
eq_or_diff( equiv_simple( 123,   456 ),   undef, 'unmatching numbers' );

done_testing;

