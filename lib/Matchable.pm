package Matchable;

# ABSTRACT: Functional language-like pattern matching, perl Moo style

use Moo::Role;

requires 'equiv';

sub against {
  my ($self, $cb, $return) = @_;
  local $_ = $self;
  local *escape = sub { $return = shift; goto done; };
  $return = $cb->();
 done:
  $return;
}

sub match {
  my ($self, $cb) = @_;
  return unless $self->equiv($_);
  local $_ = $self;
  escape($cb->());
}

1
__END__

=head1 SYNOPSIS

    package Foo;
    use Safe::Isa;
    use Moo;
    with 'Matchable';
    has val => (
      is => 'ro',
    );
    sub equiv {
      my ($self, $other) = @_;
      return unless $other->$_isa('Foo');
  	  $self->val eq $other->val;
    }
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

=head1 GOTCHAS

Watch that both against and match modify $_. I can see that it could make for some confusing bugs.

=head1 PLANS

It would be nice to get placeholders working at some point, They'd work like this in an idealised world, but I haven't thought about how to achieve it. And I probably don't want to abuse the placeholder() function like this because it's an icky way of designing things.

    use Matchable 'P';
    use Types 'Foo';
    Foo('bar')->against(sub {
      Foo(P("val"))->match(sub {
        print "Got " . placeholder->val; # Got bar
      })
    });

