#! /usr/local/bin/perl
use strict;
use warnings;

use Net::SNMP;


my $snmp_target = 'localhost';
my $snmp_port=50162;

my $enterprise = '.1.3.6.1.4.1.41717.10.1';

my ($sess, $err) = Net::SNMP->session(
    -hostname  => $snmp_target,
    -port      => $snmp_port,
    -version => 1, 
);

if (!defined $sess) {
    print "Error connecting to target ". $snmp_target . ": ". $err;
    next;
}

my @vars = qw();
my $varcounter = 1;

push (@vars, $enterprise . '.' . $varcounter);
push (@vars, OCTET_STRING);
push (@vars, "Test string");
print "@vars\n";
my $result = $sess->trap(
    -varbindlist => \@vars,
    -enterprise => $enterprise,
    -specifictrap => 1,
);

if (! $result)
{
    print "An error occurred sending the trap: " . $sess->error();
}

