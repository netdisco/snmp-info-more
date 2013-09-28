package SNMP::Info::SessionHooks;

use Role::Tiny;
use DBM::Deep;
use SNMP ();

around qw/get getnext bulkwalk/ => sub {
    my ($orig, $self) = (shift, shift);

    if ($self->{StoreSession}) {
        $self->_init_session_data
            if !defined $self->{InfoSessionData};

        if ($self->{Offline}) {
            my @res = $self->_session_retrieve(@_);
            return (wantarray() ? @res : $res[0]);
        }
    }

    my @res = ( $orig->($self, @_) );
    $self->_session_store($_[-1], $res[0]) if $self->{StoreSession};

    return (wantarray() ? @res : $res[0]);
};

sub _init_session_data {
    my $self = shift;
    my %data = ();

    $self->{SessionDataFile} ||= $self->{DestHost} .'.db';
    $self->{InfoSessionData} = DBM::Deep->new($self->{SessionDataFile})
        or die "ERROR: failed to tie to '$self->{SessionDataFile}'\n";
}

sub _session_store {
    my $self = shift;
    my ($request, $response) = @_;

    return if (ref('') eq ref($response))
           and $response =~ m/^(?:ENDOFMIBVIEW|NOSUCHOBJECT|NOSUCHINSTANCE|)$/;

    my $leaf = (ref $request) ? $request->[0] : $request;
    $leaf = SNMP::translateObj($leaf, 0, 1)
        if $leaf =~ m/^[0-9.]+$/;
    $leaf =~ s/(?:\.\d+)+$//;

    my $to_store = $response;

    if (ref($request) =~ m/Varbind/ and ref('') eq ref($response)) {
        my $iid = $request->[1];
        return unless $iid;
        return if $request->[0] !~ m/$leaf$/;

        if (exists $self->{InfoSessionData}->{$leaf}
            and $iid gt $self->{InfoSessionData}->{$leaf}->[0]->[-1]->[1]) {

            $to_store = $self->{InfoSessionData}->{$leaf}->export()->[0];
            push @$to_store, $request;
        }
        else {
            $to_store = SNMP::VarList->new($request);
        }
    }

    # use DBM::Deep->import() to avoid sharing refs with storage
    # arrayref allows us to use DBM::Deep->export() to clone
    $self->{InfoSessionData}->import( { $leaf => [ $to_store ] } );
}

# no support for getnext because when Offline => 1 we force Bulkwalk => 1
sub _session_retrieve {
    my $self = shift;
    my $request = $_[-1];

    my $leaf = (ref $request) ? $request->[0] : $request;
    $leaf = SNMP::translateObj($leaf, 0, 1)
        if $leaf =~ m/^[0-9.]+$/;
    $leaf =~ s/(?:\.\d+)+$//;

    # use DBM::Deep->export() to avoid sharing refs with storage
    return (exists $self->{InfoSessionData}->{$leaf}
        ? $self->{InfoSessionData}->{$leaf}->export()->[0] : undef);
}

1;
