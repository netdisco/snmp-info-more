package SNMP::Info::More;

use strict;
use warnings FATAL => 'all';

use Moo;
extends 'SNMP::Info', 'Moo::Object';

our $VERSION = 0.002;

around 'new' => sub {
    my ($orig, $class) = (shift, shift);

    # SNMP::Info refers to class namespace variables in new()
    # so we must get the instance manually and then re-bless.
    my $self = SNMP::Info->new(@_);
    bless $self, $class;

    return $self;
};

1;
