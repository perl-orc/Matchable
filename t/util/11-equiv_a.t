use Test::Most;
use Matchable::Util qw(equiv_a equiv_placeholder equiv_arrayref equiv_hashref ph);

# ABSTRACT: test Util::equiv_a

use lib 't/lib';
use T1;
eq_or_diff( equiv_a( 2,     2 ),     2,     'numbers equate cleanly' );
eq_or_diff( equiv_a( 'foo', 'foo' ), 'foo', 'strings equate cleanly' );

subtest 'object equate and clone' => sub {
  my $t1 = T1->new( val => 'foo' );
  my $ret = equiv_a( $t1, $t1 );
  eq_or_diff( $ret->val, 'foo', 't1s equate cleanly' );
  $ret->{'val'} = 'bar';
  eq_or_diff( $t1->val, 'foo', 't1s clone cleanly' );
};

subtest 'placeholders' => sub {

  my ( %t1, %t2 );
  my $phbar = ph('bar');

  eq_or_diff( equiv_a( $phbar, 1, \%t1 ), equiv_placeholder( $phbar, 1, \%t2 ), 'placeholders are handled correctly' );
  eq_or_diff( \%t1, \%t2, 'placeholders are set correctly' );

};

subtest arrayrefs => sub {
  my $t1 = T1->new( val => 'foo' );
  my $ret1 = equiv_a( [ $t1, $t1 ], [ $t1, $t1 ] );
  my $ret2 = equiv_arrayref( [ $t1, $t1 ], [ $t1, $t1 ] );

  eq_or_diff( $ret1, $ret2, 'arrays are handled correctly' );

  $ret1->[0]->{'val'} = 'bar';
  $ret2->[0]->{'val'} = 'bar';
  eq_or_diff( $t1->val, 'foo', 'clones cleanly' );

  eq_or_diff(
    equiv_a( [ qw(a b c d), $t1 ], [ qw(a b c d), $t1 ] ),
    equiv_arrayref( [ qw(a b c d), $t1 ], [ qw(a b c d), $t1 ] ),
    'arrays with t1 are handled correctly'
  );
};

subtest hashrefs => sub {
  my $t1 = T1->new( val => 'foo' );
  eq_or_diff(
    equiv_a( { qw(a b c), $t1 }, { qw(a b c), $t1 } ),
    equiv_hashref( { qw(a b c), $t1 }, { qw(a b c), $t1 } ),
    'hashes with t1 are handled correctly'
  );
};

subtest 'disjoint' => sub {
  my $t1 = T1->new( val => 'foo' );
  eq_or_diff( equiv_a( {}, $t1 ), undef, 'disjoint types are undef (left)' );
  eq_or_diff( equiv_a( $t1, {} ), undef, 'disjoint types are undef (right)' );
};

subtest 'sublevel placeholders' => sub {
  my $left  = T1->new( val => [ ph('val1'), ph('val2') ] );
  my $right = T1->new( val => [ 6,          12 ] );

  my %ph;
  my $ret = equiv_a( $left, $right, \%ph );

  eq_or_diff( $ret, T1->new( val => [ 6, 12 ] ), 'placeholders at sublevels are processed properly' );
  eq_or_diff( \%ph, { val1 => 6, val2 => 12 }, 'placeholders at sublevels are set properly' );
};

subtest 'multiside sublevel placeholders' => sub {
  my ( %t1, %t2 );
  my $left      = T1->new( val => [ { a => \%t2,         b => ph('foobar'), } ] );
  my $right     = T1->new( val => [ { a => ph('bazfoo'), b => \%t1, } ] );
  my $composite = T1->new( val => [ { a => \%t2,         b => \%t1 } ] );
  my %ph;
  my $ret = equiv_a( $left, $right, \%ph );
  eq_or_diff( $ret, $composite, 'placeholders at sublevels on both sides are processed properly' );
  eq_or_diff( \%ph, { foobar => \%t1, bazfoo => \%t2 }, 'placeholders at sublevels on both sides are set correctly' );
};

subtest 'collisions' => sub {
  my $t1 = T1->new( val => 'foo' );
  my $phfoo = ph('foo');
  my %ph;

  equiv_a( $t1, $phfoo, \%ph );
  eq_or_diff( \%ph, { foo => $t1 }, 'placeholders are set correctly' );

  throws_ok {
    equiv_a( $t1, $phfoo, \%ph );
  }
  qr/Placeholder 'foo' already exists, refusing to overwrite/;

};

done_testing;

