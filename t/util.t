use Test::Most;

# This could use a little work really. It's horribly messy for one thing.
# Also I'd like to see some more testing around subclasses of matchables

use Matchable::Util qw(
  matchable add_placeholder equiv_simple equiv_matchable equiv_placeholder
  equiv_arrayref equiv_hashref equiv_ref equiv_a equiv ph isa_ph isa_ph_or
);

use Scalar::Util 'blessed';
use lib 't/lib';
use T1;

my $phfoo = ph('foo');
my $phbar = ph('bar');
my $t1 = T1->new(val=>'foo');
my %ph;
my $phbaz = ph('baz');
my $ph    = {};
my $ret;

# equiv_arrayref
# equiv_hashref
# equiv_ref
# equiv_a
# equiv

# equiv_hash
eq_or_diff(equiv_hashref(+{qw(a b c d)},+{qw(a b c d)}),+{qw(a b c d)}, "equiv_hash: strings equate cleanly");
$ret = equiv_hashref(+{a => $t1, b => $t1},+{a => $t1, b => $t1});
eq_or_diff({a => $ret->{'a'}->val, b => $ret->{'b'}->val},{a => $t1->val, b => $t1->val}, "equiv_hash: mixed types inc t1 equate cleanly");

eq_or_diff(equiv_a(2,2),2, "equiv_a: numbers equate cleanly");
eq_or_diff(equiv_a("foo","foo"),"foo", "equiv_a: strings equate cleanly");
$ret = equiv_a($t1,$t1);
eq_or_diff($ret->val,'foo', "equiv_a: t1s equate cleanly");
$ret->{'val'} = 'bar';
eq_or_diff($t1->val,'foo', "equiv_a: t1s clone cleanly");
my (%t1, %t2);
eq_or_diff(equiv_a($phbar,1,\%t1), equiv_placeholder($phbar,1,\%t2),"equiv_a: placeholders are handled correctly");
eq_or_diff(\%t1, \%t2, "equiv_a: placeholders are set correctly");
my $ret1 = equiv_a([$t1,$t1],[$t1,$t1]);
my $ret2 = equiv_arrayref([$t1,$t1],[$t1,$t1]);
eq_or_diff($ret1, $ret2, "equiv_a: arrays are handled correctly");
$ret1->[0]->{'val'} = "bar";
$ret2->[0]->{'val'} = "bar";
eq_or_diff($t1->val,'foo', "equiv_a: clones cleanly");
eq_or_diff(equiv_a([qw(a b c d), $t1],[qw(a b c d), $t1]),
           equiv_arrayref([qw(a b c d), $t1],[qw(a b c d), $t1]), "equiv_a: arrays with t1 are handled correctly");
eq_or_diff(equiv_a({qw(a b c), $t1},{qw(a b c), $t1}),
           equiv_hashref({qw(a b c), $t1},{qw(a b c), $t1}), "equiv_a: hashes with t1 are handled correctly");
eq_or_diff(equiv_a({},$t1),undef, "equiv_a: disjoint types are undef (left)");
eq_or_diff(equiv_a($t1,{}),undef, "equiv_a: disjoint types are undef (right)");
%ph = ();
$ret = equiv_a(T1->new(val => [ph('val1'), ph('val2')]), T1->new(val => [6,12]), \%ph);
eq_or_diff($ret, T1->new(val => [6,12]), "equiv_a: placeholders at sublevels are processed properly");
eq_or_diff(\%ph, {val1 => 6, val2 => 12}, "equiv_a: placeholders at sublevels are set properly");
%ph = ();
$ret = equiv_a(
  T1->new(val => [
    {
      a => \%t2,
      b => ph('foobar'),
    }
  ]),
  T1->new(val => [
    {
      a => ph('bazfoo'),
      b => \%t1,
    }
  ]),
  \%ph
);
eq_or_diff($ret, T1->new(val => [{a=>\%t2,b=>\%t1}]), "equiv_a: placeholders at sublevels on both sides are processed properly");
eq_or_diff(\%ph, {foobar => \%t1, bazfoo => \%t2},    "equiv_a: placeholders at sublevels on both sides are set correctly");
%ph = ();
equiv_a($t1,$phfoo,\%ph);
eq_or_diff(\%ph,{foo=>$t1}, "equiv_a: placeholders are set correctly");
throws_ok {
  equiv_a($t1,$phfoo,\%ph);
} qr/Placeholder 'foo' already exists, refusing to overwrite/;
# equiv
($ret, $ph) = equiv(
  T1->new(val => [
    {
      a => \%t2,
      b => ph('foobar'),
    }
  ]),
  T1->new(val => [
    {
      a => ph('bazfoo'),
      b => \%t1,
    }
  ]),
);
eq_or_diff($ret, T1->new(val => [{a=>\%t2,b=>\%t1}]), "equiv: placeholders at sublevels on both sides are processed properly");
eq_or_diff($ph,  {foobar => \%t1, bazfoo => \%t2},    "equiv: placeholders at sublevels on both sides are set correctly");
# - it basically punts the list of attributes to equiv_a

done_testing;
