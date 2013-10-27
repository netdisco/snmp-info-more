package SNMP::Info::More;

use strict;
use warnings FATAL => 'all';

use Moo;

extends 'SNMP::Info', 'Moo::Object';
with 'SNMP::Info::More::Offline';

our $VERSION = 0.002;

around 'new' => sub {
  my ($orig, $class) = (shift, shift);

  # SNMP::Info refers to class namespace variables in new()
  # so we must get the instance manually and then re-bless.
  my $self = SNMP::Info->new(@_);
  bless $self, $class;

  return $self;
};

# a bit of not very dark magic to allow wrapping of _global
# and _load_attr which are simple functions, not methods.
sub _subref {
  my $sub = shift;
  my $pkg = shift || scalar caller(0);

  my $symtbl = \%{main::};
  foreach my $part(split /::/, $pkg) {
      $symtbl = $symtbl->{"${part}::"};
  }

  return eval{ \&{ $symtbl->{$sub} } };
}

1;
