use Test::Most;
use Matchable::Util qw(ph isa_ph);

# ABSTRACT: Util qw(isa_ph) tests

my $phfoo = ph('foo');

eq_or_diff( isa_ph('foo'),  undef, 'strings are undef' );
eq_or_diff( isa_ph(123),    undef, 'numbers are undef' );
eq_or_diff( isa_ph(qr//),   undef, 'regexrefs are undef' );
eq_or_diff( isa_ph($phfoo), 1,     'placeholders are 1' );

done_testing;

