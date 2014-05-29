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
my ( %t1, %t2 );

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
