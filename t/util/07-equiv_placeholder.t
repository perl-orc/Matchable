use Test::Most;

# ABSTRACT: test Util::equiv_placeholder

use Matchable::Util qw(equiv_placeholder ph);

use lib 't/lib';
use T1;

subtest complex_classes => sub {
  my $phfoo = ph('foo');
  my $t1 = T1->new( val => 'foo' );
  my %ph;
  my $ret = equiv_placeholder( $phfoo, $t1, \%ph );
  eq_or_diff( $ret->val, 'foo', "complex classes are returned" );
  $ret->{'val'} = "bar";
  eq_or_diff( $t1->val, 'foo', "clones cleanly" );
};

subtest multi_call_complex => sub {
  my $phfoo = ph('foo');
  my $phbar = ph('bar');
  my $t1    = T1->new( val => 'foo' );
  my %ph;

  my $reta = equiv_placeholder( $phfoo, $t1, \%ph );
  $reta->{'val'} = 'bar';
  my $retb = equiv_placeholder( 12, $phbar, \%ph );
  eq_or_diff( $retb, 12, "numeric data are returned" );
  eq_or_diff( \%ph, { foo => $t1, bar => 12 }, "placeholders have been set correctly" );
};

subtest array_placeholders => sub {
  my %ph;
  my $phfoo = ph('foo');
  my $phbar = ph('bar');

  eq_or_diff( equiv_placeholder( $phfoo, [qw(foo bar)], \%ph ), [qw(foo bar)], "ARRAY refs are looped (left)" );
  eq_or_diff( equiv_placeholder( [qw(bar foo)], $phbar, \%ph ), [qw(bar foo)], "ARRAY refs are looped (right)" );
  eq_or_diff( \%ph, { foo => [qw(foo bar)], bar => [qw(bar foo)] }, "placeholders have been set correctly" );
};

subtest 'hash_placeholders' => sub {
  my %ph;
  my $phfoo = ph('foo');
  my $phbar = ph('bar');

  eq_or_diff( equiv_placeholder( $phfoo, {qw(foo bar baz quux)}, \%ph ), {qw(foo bar baz quux)}, "HASH refs are looped (left)" );
  eq_or_diff( equiv_placeholder( {qw(bar foo quux baz)}, $phbar, \%ph ), {qw(bar foo quux baz)}, "HASH refs are looped (right)" );
  eq_or_diff( \%ph, { foo => {qw(foo bar baz quux)}, bar => {qw(bar foo quux baz)} }, "placeholders have been set correctly" );
};

subtest 'placeholder collisions' => sub {
  my $phfoo = ph('foo');
  my %ph    = (
    foo => {qw( foo bar baz quux )},
    bar => {qw( bar foo quux baz )},
  );
  my $t1 = T1->new( val => 'foo' );
  throws_ok {
    equiv_placeholder( $t1, $phfoo, \%ph );
  }
  qr/Placeholder 'foo' already exists, refusing to overwrite/;
};

subtest 'too many placeholders' => sub {
  my $phfoo = ph('foo');
  my $phbar = ph('bar');

  throws_ok {
    equiv_placeholder( $phfoo, $phbar );
  }
  qr/You may only provide a single placeholder/;
  throws_ok {
    equiv_placeholder( 1, 2 );
  }
  qr/You must provide a single placeholder/;
};

done_testing;

