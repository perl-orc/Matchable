use Test::Most;

use Matchable qw( ph isa_ph isa_ph_or );
use lib 't/lib';
use T1;

subtest 'against' => sub {

  my $t1 = T1->new( val => 'foo' );
  my $inner;
  $t1->against( sub { $inner = $_; } );
  eq_or_diff( $inner, $t1, 'against aliases invocant to _ in callback' );

};

subtest 'matches _' => sub {
  my $t1 = T1->new( val => 'foo' );
  local $_ = $t1;
  no warnings 'redefine';
  local *Matchable::escape = sub { };
  my $called;
  $t1->match( sub { $called = 1 } );
  eq_or_diff( $called, 1, 't1 matches against itself in _, triggering callback' );
};

subtest 'matches _ different attr' => sub {
  my $t1 = T1->new( val => 'foo' );
  my $t2 = T1->new( val => 'bar' );
  local $_ = $t1;
  no warnings 'redefine';
  local *Matchable::escape = sub { };
  my $called;
  $t2->match( sub { $called = 1 } );
  eq_or_diff( $called, undef, 't2 should not match t1, trigger shouldnt callback' );
};

subtest 'matches _ if cond(0)' => sub {
  my $t1 = T1->new( val => 'foo' );
  local $_ = $t1;
  no warnings 'redefine';
  local *Matchable::escape = sub { };
  my $called;
  $t1->match_if(
    sub {
      $called = 1;
    },
    sub { 0 }
  );
  eq_or_diff( $called, undef, 'Condition doest match == code doesnt run' );
};

subtest 'matches _ if cond(1)' => sub {
  my $t1 = T1->new( val => 'foo' );
  local $_ = $t1;
  no warnings 'redefine';
  local *Matchable::escape = sub { };
  my $called;
  $t1->match_if(
    sub {
      $called = 1;
    },
    sub { 1 }
  );
  eq_or_diff( $called, 1, 'Condition does match == code runs' );
};

subtest "compount against/match" => sub {

  my $t1 = T1->new( val => 'foo' );

  my $leaky = '';

  my $ret = $t1->against(
    sub {

      # Using $_ to prove that we can get the current item in the subref
      T1->new( val => 'bar' )->match( sub { $leaky .= 'bar' . $_->val } );
      T1->new( val => 'foo' )->match( sub { $leaky .= 'foo' . $_->val } );

      # If it didn't fall out, it'll add this again, and the tests will fail
      T1->new( val => 'foo' )->match( sub { $leaky .= 'foo' . $_->val } );
    }
  );
  eq_or_diff( $ret, 'foofoo', 'match/against: The correct function was called, execution was terminated after' );
};

done_testing;
