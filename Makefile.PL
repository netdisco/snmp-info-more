use inc::Module::Install;
 
name     'SNNP-Info-Offline';
license  'bsd';
all_from 'lib/SNMP/Info/Offline.pm';
 
requires 'Moo' => 0;
requires 'DBM::Deep' => 0;

WriteAll;
