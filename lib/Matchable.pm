package Matchable;

# ABSTRACT: Functional language-like pattern matching, perl Moo style

no autovivification;
use Carp qw(carp croak);
use Clonable::Util qw(arrayref);
use Matchable::Util qw(equiv_matchable);
use Safe::Isa;
use Scalar::Util 'blessed';

use Moo::Role;
with 'Clonable';

has _matchable_attrs => (
  is => 'ro',
  isa => sub{die("Expected arrayref for '_matchable_attrs'") unless arrayref(shift);},
  default => sub {[]},
);

sub against {
  my ($self, $cb, $return) = @_;
  local $_ = $self;
  local *escape = sub { $return = shift; goto done; };
  $return = $cb->();
 done:
  return $return;
}

sub match {
  my ($self, $cb) = @_;
  my $ph = {};
  my $ret = equiv_matchable($_,$self,$ph) || return undef;
  local $_ = $ret;
  escape($cb->($ph));
}

sub match_if {
  my ($self, $cb, $pred) = @_;
  croak('match_if: $pred is not a coderef!') unless coderef($pred);
  return $pred->($self) ? $self->match($cb) : undef
}

1
__END__

=head1 SYNOPSIS

    package Foo;
    use Moo;
    with 'Matchable';
    # The value this example object stores
    has val => (
      is => 'ro',
    );
    has '+_matchable_fields' => (
      default => sub {["val"]},
    );
    1

And over in your main file:

    use Foo;
    Foo->new(val=>'foo')->against(sub {
      Foo->new(val=>'bar')->match(sub {
        print "val is bar";
      });
      # ->against sets $_ to the thing being matched against
      $_->match(sub {
        # And match sets $_ to the thing that successfully matched
        print "val is " . $_->val; # val is foo
      });
    });

Here's a nice way to tidy code up:

    package Types;Thi
    use Exporter;
    use Foo;
    our @ISA = qw(Exporter);
    @EXPORT_OK = qw(Foo);
    sub Foo {
      my ($self, $val) = @_;
      Foo->new(val => $val)
    }
    1

Then the main becomes:

    use Types 'Foo';
    Foo('foo')->against(sub {
      Foo('bar')->match(sub {
        print "val is bar";
      });
      $_->match(sub {
        print "val is " . $_->val; # val is foo
      });
    });

=head1 PLACEHOLDERS

You can use placeholders to represent unknown values that you'd like to bind as follows:

    use Matchable::Util 'ph';
    Bar('foo',ph('bar'))->against(sub {
      Bar(ph('foo'),'bar')->match(sub {
        my $ph = shift;
        print "foo: " . $ph->{'foo'}. ", bar: " .$ph->{'bar'};
      });
    });

=head1 ARBITRARY PREDICATES

You can pass in a predicate that accepts a constructed argument and returns a truthy or falsey value. Yes, it works with placeholders

    $_->match_if(sub{print "Only run when Foo's val is 'bar'"},sub{shift->val eq 'bar'});

=head1 GOTCHAS

Watch that both against and match modify $_. I can see that it could make for some confusing bugs.
