use Test::Most;

# ABSTRACT: Test Util::equiv_hashref

use Matchable::Util qw(equiv_hashref);

use lib 't/lib';
use T1;

eq_or_diff( equiv_hashref( +{qw(a b c d)}, +{qw(a b c d)} ), +{qw(a b c d)}, 'strings equate cleanly' );

my $t1 = T1->new( val => 'foo' );
my $ret = equiv_hashref( +{ a => $t1, b => $t1 }, +{ a => $t1, b => $t1 } );
eq_or_diff(
  { a => $ret->{'a'}->val, b => $ret->{'b'}->val },
  { a => $t1->val,         b => $t1->val },
  'mixed types inc t1 equate cleanly'
);

done_testing;

