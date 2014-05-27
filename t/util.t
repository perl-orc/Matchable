use Test::Most;

# This could use a little work really. It's horribly messy for one thing.
# Also I'd like to see some more testing around subclasses of matchables

use Matchable::Util qw(
  matchable add_placeholder equiv_simple equiv_matchable equiv_placeholder
  equiv_arrayref equiv_hashref equiv_ref equiv_a equiv ph isa_ph isa_ph_or
);

use Scalar::Util 'blessed';
{
  package T1;
  # ABSTRACT: T1 is a class that conforms to what we expect of a matchable
  use Safe::Isa;
  use Scalar::Util 'blessed';
  use Moo;
  with 'Matchable';
  has val => (
    is => 'ro',
  );
  has '+_clonable_attrs' => (
    default => sub {['val']},
  );
  has '+_matchable_attrs' => (
    default => sub {['val']},
  );
}

eq_or_diff(matchable(T1->new),1,"matchable: T1");
eq_or_diff(matchable({}),undef,"matchable: Hashref");

my $phfoo = ph('foo');
eq_or_diff(blessed($phfoo),'Matchable::Placeholder',"ph: foo is a placeholder");
eq_or_diff($phfoo->name,'foo',"ph: foo's name is foo");
my $phbar = ph('bar');
eq_or_diff(blessed($phbar),'Matchable::Placeholder',"ph: bar is a placeholder");
eq_or_diff($phbar->name,'bar',"ph: bar's name is bar");

eq_or_diff( isa_ph('foo'),  undef, "isa_ph: strings are undef");
eq_or_diff( isa_ph(123),    undef, "isa_ph: numbers are undef");
eq_or_diff( isa_ph(qr//),   undef, "isa_ph: regexrefs are undef");
eq_or_diff( isa_ph($phfoo), 1,     "isa_ph: placeholders are 1");
my @classes = qw(Foo Bar Baz T1 Quux);
eq_or_diff( isa_ph_or('foo'            ), undef, "isa_ph_or: basic types are undef");
eq_or_diff( isa_ph_or($phfoo           ), 1,     "isa_ph_or: matchables are 1");
eq_or_diff( isa_ph_or(T1->new          ), undef, "isa_ph_or: empty class lists return undef for non-matchables");
eq_or_diff( isa_ph_or($phfoo           ), 1,     "isa_ph_or: empty class lists return 1 for matchables");
eq_or_diff( isa_ph_or(T1->new, @classes), 1,     "isa_ph_or: the whole list is searched");

my $ph = {};
add_placeholder('foo','bar',$ph);
eq_or_diff($ph,{foo => 'bar'}, 'add_placeholder: foo added correctly');
add_placeholder('bar','baz',$ph);
eq_or_diff($ph,{foo => 'bar', bar => 'baz'}, 'add_placeholder: bar added correctly');

eq_or_diff(equiv_simple('foo','foo'),'foo', "equiv_simple: matching strings");
eq_or_diff(equiv_simple('foo','bar'),undef, "equiv_simple: unmatching strings");
eq_or_diff(equiv_simple(123,123),123, "equiv_simple: matching numbers");
eq_or_diff(equiv_simple(123,456),undef, "equiv_simple: unmatching numbers");

my $t1 = T1->new(val=>'foo');
my %ph;
my $phbaz = ph('baz');
my $ret = equiv_placeholder($phfoo,$t1,\%ph);
eq_or_diff($ret->val,'foo',"equiv_placeholder: complex classes are returned");
$ret->{'val'} = "bar";
eq_or_diff($t1->val,'foo',"equiv_placeholder: clones cleanly");
$ret = equiv_placeholder(12,$phbar,\%ph),
eq_or_diff($ret, 12,"equiv_placeholder: numeric data are returned");
eq_or_diff(\%ph,{foo=>$t1,bar=>12},"equiv_placeholder: placeholders have been set correctly");
%ph = ();
eq_or_diff(equiv_placeholder($phfoo,[qw(foo bar)],\%ph),[qw(foo bar)],"equiv_placeholder: ARRAY refs are looped (left)");
eq_or_diff(equiv_placeholder([qw(bar foo)],$phbar,\%ph),[qw(bar foo)],"equiv_placeholder: ARRAY refs are looped (right)");
eq_or_diff(\%ph,{foo=>[qw(foo bar)],bar =>[qw(bar foo)]},"equiv_placeholder: placeholders have been set correctly");
%ph = ();
eq_or_diff(equiv_placeholder($phfoo,{qw(foo bar baz quux)},\%ph),{qw(foo bar baz quux)},"equiv_placeholder: HASH refs are looped (left)");
eq_or_diff(equiv_placeholder({qw(bar foo quux baz)},$phbar,\%ph),{qw(bar foo quux baz)},"equiv_placeholder: HASH refs are looped (right)");
eq_or_diff(\%ph,{foo=>{qw(foo bar baz quux)},bar =>{qw(bar foo quux baz)}},"equiv_placeholder: placeholders have been set correctly");
throws_ok {
  equiv_placeholder($t1,$phfoo,\%ph);
} qr/Placeholder 'foo' already exists, refusing to overwrite/;
throws_ok {
  equiv_placeholder($phfoo,$phbar);
} qr/equiv_placeholder: You may only provide a single placeholder/;
throws_ok {
  equiv_placeholder(1,2);
} qr/equiv_placeholder: You must provide a single placeholder/;

eq_or_diff(equiv_matchable($t1,$t1)->val,'foo', "equiv_matchable: matchables are cloned correctly");
# equiv_arrayref
# equiv_hashref
# equiv_ref
# equiv_a
# equiv

eq_or_diff(equiv_arrayref([1,2,3],     [1,2,3]),     [1,2,3],     "equiv_arrayref: integers equate cleanly");
eq_or_diff(equiv_arrayref([qw(a b c)], [qw(a b c)]), [qw(a b c)], "equiv_arrayref: strings equate cleanly");
eq_or_diff(equiv_arrayref({},          []),          undef,       "equiv_arrayref: when one argument is a hashref, undef (left)");
eq_or_diff(equiv_arrayref([],          {}),          undef,       "equiv_arrayref: when one argument is a hashref, undef (right)");
eq_or_diff(equiv_arrayref([1..3],      [4..6]),      undef,       "equiv_arrayref: unequivalent ARRAYs are undef");
$ret = equiv_arrayref([$t1,$t1],[$t1,$t1]);
eq_or_diff($ret->[0]->val,'foo','equiv_arrayref: arrays equate cleanly 1');
eq_or_diff($ret->[1]->val,'foo','equiv_arrayref: arrays equate cleanly 2');
$ret->[0]->{'val'} = 'bar';
eq_or_diff($t1->val, 'foo', "equiv_arrayref: t1s clone cleanly");
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
