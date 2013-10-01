use inc::Module::Install;
 
name     'SNNP-Info-More';
license  'bsd';
all_from 'lib/SNMP/Info/More.pm';
 
requires 'Moo' => 0;
requires 'DBM::Deep' => 0;

WriteAll;
