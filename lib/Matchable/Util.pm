package Matchable::Util;

use Carp qw(carp croak);
use Clonable::Util qw(arrayref hashref clone_a);
use Exporter;
use List::MoreUtils qw(pairwise);
use Matchable::Placeholder;
use Safe::Isa;
use Scalar::Util 'blessed';

use Data::Dumper 'Dumper';

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
  matchable
  add_placeholder
  equiv_simple equiv_matchable equiv_placeholder equiv_arrayref equiv_hashref equiv_ref
  equiv_a equiv
  ph
  isa_ph isa_ph_or
);

sub matchable { shift->$_does('Matchable') || undef; }

sub add_placeholder {
  my ($name, $value, $placeholders) = @_;
  croak("Placeholder '$name' already exists, refusing to overwrite!") if defined $placeholders->{$name};
  $placeholders->{$name} = $value;
}

sub equiv_simple {
#  warn "equiv_simple: " . Dumper \@_;
  my ($l, $r, $p) = @_;
  return (("$l" eq "$r") ? $l : undef);
}

sub equiv_matchable {
  my ($l, $r, $p) = @_;
  croak("equiv_matchable: we require two matchable objects") unless matchable($l) && matchable($r);
  # Left may be more specific than right
  return undef unless $l->$_isa(blessed($r));
#  warn "_matchable_attrs(l): " . Dumper($l->_matchable_attrs);
#  warn "_matchable_attrs(r): " . Dumper($r->_matchable_attrs);
  # Since right may be less specific, we can only compare those attributes
  my %new = map {
    my @ret = equiv_attr( $l, $r, $_, $p );

    #    warn 'ret: ' . Dumper \@ret;
    return undef unless defined $ret[0];
    @ret
  } @{$r->_matchable_attrs};
  # But now we may be missing a few...
  map {
    my $old = $_;
    unless (grep {$_ eq $old} @{$r->_matchable_attrs}) {
      $new{$old} = clone_a($l->$old);
    }
  } @{$l->_matchable_attrs};
#  warn Dumper(\%new);
  my $pkg = blessed($l);
  return $pkg->new(%new);
}

sub equiv_placeholder {
  my ($l, $r, $p) = @_;
#  warn "equiv_placeholder: " . Dumper \@_;
  croak("equiv_placeholder: You may only provide a single placeholder") if (isa_ph($l) && isa_ph($r));
  croak("equiv_placeholder: You must provide a single placeholder") unless (isa_ph($l) || isa_ph($r));
  my ($real,$fake) = (isa_ph($l) ? ($r, $l) : ($l, $r));
  add_placeholder($fake->name, $real, $p);
#  warn "p" . Dumper $p;
  $ret = clone_a($real, $p);
#  warn 'ret: ' . Dumper $ret;
  $ret;
}

sub equiv_arrayref {
  my ($l,$r,$p) = @_;
#  warn "equiv_arrayref: " . Dumper \@_;
  croak("equiv_arrayref: you must provide an arrayref") unless arrayref($l) || arrayref($r);
  return undef unless (arrayref($l) && arrayref($r));
  return undef unless (@$l == @$r);
  my @ret = map {
    my $ret = equiv_a($_->[0],$_->[1],$p);
#    warn "ret: $ret";
    return undef unless defined $ret;
    $ret
  } pairwise {[$a,$b]} @$l, @$r;
  return [@ret];
}

sub equiv_hashref {
  my ($l, $r, $p) = @_;
#  warn "equiv_hashref: " . Dumper \@_;
  croak("equiv_hashref: you must provide a hashref") unless hashref($l) || hashref($r);
  return undef unless hashref($l) && hashref($r);
  return undef unless (join(",", sort keys %$left)) eq (join(",", sort keys %$right));
  my %ret = map {
      $ret = equiv_a($l->{$_},$r->{$_},$p) // return undef;
#      warn "ret: " . Dumper $ret;
      ($_ => $ret);
  } (keys %$l);
#  warn Dumper \%ret;
  return {%ret};
}

sub equiv_ref {
  my ($l, $r, $p) = @_;
  return undef unless ref($l) eq ref($r);
  return equiv_arrayref(@_) if arrayref($l);
  return equiv_hashref(@_) if hashref($l);
  return equiv_matchable(@_) if matchable($l);
  croak("Don't know what to do with ref type '" . ref($l) . "'");
}

sub equiv_a {
  my ($l, $r, $p) = @_;
#  warn "equiv_a: " . Dumper \@_;
  return equiv_placeholder(@_) if isa_ph($l) || isa_ph($r);
  return equiv_ref(@_) if ref($l) or ref($r);
  return equiv_simple(@_);
}

sub equiv_attr {
  my ($l, $r, $a, $p) = @_;
#  warn "equiv_attr: $a";
  my $ret = equiv_a($l->$a, $r->$a, $p);
#  warn "ret: " . Dumper $ret;
  return undef unless $ret;
  return ($a => $ret);
}

sub equiv {
  my ($left, $right, $placeholders) = @_;
  $placeholders ||= {};
  return equiv_a($left, $right, $placeholders);
}

sub ph (*;$) {
  my ($name, $isa) = @_;
  $name =~ s/(.+::)(?=[a-z]+)$//i;
  Matchable::Placeholder->new(name => $name, isa => $isa);
}

sub isa_ph {
  shift->$_isa("Matchable::Placeholder") || undef;
}

sub isa_ph_or {
  my ($item,@classes) = @_;
  return 1 if isa_ph($item);
  return undef unless @classes;
  grep {return 1 if $item->$_isa($_)} @classes;
  return undef;
}

1
__END__
