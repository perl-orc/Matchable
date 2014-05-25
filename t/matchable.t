use Test::Most;

{
  package T1;
  use Safe::Isa;
  use Moo;
  with 'Matchable';
  has val => (
    is => 'ro',
  );
  sub equiv {
    my ($self, $other) = @_;
    return unless $other->$_isa('T1');
	$self->val eq $other->val;
  }
}

my $leaky;
eq_or_diff(T1->new(val=>'foo')->against(sub{
  T1->new(val => 'bar')->match(sub {
    # Using $_ to prove that we can get the current item in the subref
    $leaky .= 'bar'.$_->val;
  });
  T1->new(val => 'foo')->match(sub {
    $leaky .= 'foo'.$_->val;
  });
  # If it didn't fall out, it'll add this again, and the tests will fail
  T1->new(val => 'foo')->match(sub {
    $leaky .= 'foo'.$_->val;
  });
}),'foofoo');

done_testing;
