use Test::Most;

# ABSTRACT: Test Util::add_placeholder

use Matchable::Util qw(add_placeholder);

my $ph = {};

add_placeholder( 'foo', 'bar', $ph );
eq_or_diff( $ph, { foo => 'bar' }, 'foo added correctly' );

add_placeholder( 'bar', 'baz', $ph );
eq_or_diff( $ph, { foo => 'bar', bar => 'baz' }, 'bar added correctly' );

done_testing;

