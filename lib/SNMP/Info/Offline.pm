package SNMP::Info::Offline;

use strict;
use warnings FATAL => 'all';

use base 'SNMP::Info';

our $VERSION = 0.001;

use Moo;
use Role::Tiny ();

around 'new' => sub {
    my $orig = shift;
    my $self = $orig->(@_);
    $self->_inject_session_role;
    return $self;
};

sub _inject_session_role {
    my $self = shift;
    my $session = $self->session;

    unless ($session->can('does_role')
            and $session->does_role('SNMP::Info::Session')) {

        # XXX This alters SNMP::Session globally for the process.
        # An alternative would be to use apply_roles_to_object()
        # but then we'd have to work hard to capture the test in
        # SNMP::Info's snmp_connect_ip (a sneaky connection!) XXX

        Role::Tiny->apply_roles_to_package(
            'SNMP::Session',
            'SNMP::Info::SessionHooks',
        );
    }
}

around 'store_session' => sub {
    my ($orig, $self) = (shift, shift);
    # that's it, we let SNMP::Info::Session take care of store/retrieve
};

1;
