#!/usr/bin/perl

use strict; use warnings FATAL => 'all';
use Test::More 0.88;

BEGIN { use_ok 'SNMP::Info::More' }

my $s = SNMP::Info::More->new(
    DestHost => 'localhost',
    # Debug => 1,
    Version => 2,
    IgnoreNetSNMPConf => 1,
    AutoSpecify => 0,
) or die "cant connect";

my $err = $s->error();
die "SNMP Community or Version probably wrong connecting to device. $err\n" if defined $err;

ok ($s->uptime);

done_testing;
