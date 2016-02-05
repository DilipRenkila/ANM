#!/usr/bin/perl

use DBI;
use Net::SNMP;
use FindBin;

$pwd=$FindBin::Bin;@split=split("/",$pwd);pop(@split);push(@split,"db.conf");$realpath=join("/",@split);
do "$realpath";
print "HI\n";
my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$username,$password);


$sth = $connect->prepare("CREATE TABLE IF NOT EXISTS `Trap`( `id` int(11) NOT NULL AUTO_INCREMENT, `STATUS` tinytext NOT NULL, `Message` tinytext NOT NULL, `TIME` tinytext NOT NULL, `prev_status` tinytext NOT NULL, `prev_time` tinytext NOT NULL, PRIMARY KEY (`id`) )ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1");
$sth->execute();


my $TRAP_FILE = "/home/dilip/et2536-dire15/ASSIGNMENT3/trap.log";

my $host = <STDIN>;	
 chomp($host);
my $ip = <STDIN>;	
 chomp($ip);

while(<STDIN>) {
        chomp($_);
        push(@vars,$_);
}


open(TRAPFILE, ">> $TRAP_FILE");
$date = `date`;
chomp($date);
print(TRAPFILE "New trap received: $date for \nHOST: $host\nIP: $ip\n");

foreach(@vars) 
{
        print(TRAPFILE "TRAP: $_\n");
	@var=split(/\ /,$_);
	if("$var[0]" eq "iso.3.6.1.4.1.41717.10.1")
	{
	 $IP=$var[1];
	}
	if("$var[0]" eq "iso.3.6.1.4.1.41717.10.2") 
	{
	 if($var[1]==0)
	 {
	  $status = "OK";
	 }
	 if($var[1]==1)
	 {
	  $status = "PROBLEM";
	 }
	 if($var[1]==2)
	 {	
	  $status = "DANGER";
	 }
	 if($var[1]==3)
	 {	
	  $status = "FAIL";
	 }
	}

$time=time;
 #print (TRAPFILE "DONE FILING: $IP, $status\n");
if($IP && $status)
{
$sth=$connect->prepare("select `Message` from `Traps` where Message='$IP'");
$sth->execute();
while($data=$sth->fetchrow_array())
{
push(@ip,$data);
}
if($IP~~@ip)
{
$sth=$connect->prepare("select `STATUS` from `Traps` where Message='$IP'");
$sth->execute();
while($prevstat=$sth->fetchrow_array())
{
$sth=$connect->prepare("UPDATE `Traps` SET `prev_status`='$prevstat' where `Message`='$IP'");
$sth->execute();
}

$sth=$connect->prepare("select `TIME` from `Traps` where Message='$IP'");
$sth->execute();
while($prevtime=$sth->fetchrow_array())
{
$sth=$connect->prepare("UPDATE `Traps` SET `prev_time`='$prevtime' where `Message`='$IP'");
$sth->execute();
}
$sth=$connect->prepare("UPDATE `Traps` SET `STATUS`='$status', `TIME`='$time' where `Message`='$IP'");
$sth->execute();
}
else
{
$sth=$connect->prepare("INSERT into `Traps` (Message,STATUS,TIME) VALUES ('$IP','$status','$time')");
$sth->execute();
}

if("$status" eq "FAIL")
{
print(TRAPFILE "Sending FAIL trap\n");

$sth=$connect->prepare("Select * from `red`");
$sth->execute();

while(@abt=$sth->fetchrow_array())
{
$i=$abt[1];
$p=$abt[2];
$c=$abt[3];
}

$host="$i:$p";
$community="$c";
my($session,$error)=Net::SNMP->session(
	-hostname=>$host,
	-community=>$community,	
	-version=>1,
);
if(!defined $session) {
print "Error connecting to target".$session.".".$error;
}
$sth= $connect->prepare("select * from `Traps` where Message='$IP'");
$sth->execute();

while(@fail=$sth->fetchrow_array())
{
$status=$fail[1];
$ip=$fail[2];
$prevst=$fail[4];
$prevtim=$fail[5];
}
$trapoid= '1.3.6.1.4.1.41717.20.1';
@trapoids=($trapoid,OCTET_STRING,$ip);
push(@trapoids,"1.3.6.1.4.1.41717.20.2",OCTET_STRING,"$time");
push(@trapoids,"1.3.6.1.4.1.41717.20.3",OCTET_STRING,"$prevst");
push(@trapoids,"1.3.6.1.4.1.41717.20.4",OCTET_STRING,"$prevtim");

my $result= $session->trap(
	-varbindlist	=>\@trapoids
);

if(!defined $result) {
print "Error connecting to target".$session.".".$error;
}
}

if("$status" eq "DANGER")
{
$sth= $connect->prepare("select * from `Traps`");
$sth->execute();
$y=0;
while(@fail=$sth->fetchrow_array())
{
$status=$fail[1];
$ip=$fail[2];
$prevst=$fail[4];
$prevtim=$fail[5];
if("$status" eq "DANGER")
{
#print(TRAPFILE "SENDING DANGER TRAP\n");
$y++;
#print(TRAPFILE "$y\n");	 
}
}
if($y >1)
{
$sth= $connect->prepare("SELECT * FROM `red`");
$sth->execute();
#print(TRAPFILE "sending danger trap\n");
while(@abt=$sth->fetchrow_array())
{
$i=$abt[1];
$p=$abt[2];
$c=$abt[3];
}
print(TRAPFILE "in if trap\n");
$host="$i:$p";
$community="$c";
my($session,$error)=Net::SNMP->session(
	-hostname=>$host,
	-community=>$community,	
	-version=>1,
);

	if (!defined($session)) {
        printf("ERROR: %s.\n", $error);
    	exit 1;
	}
$sth=$connect->prepare("SELECT * FROM `Traps` where `STATUS`='DANGER'");
$sth->execute;
$t=1;

while(@axt=$sth->fetchrow_array())
{
$status=$axt[1];
$ip=$axt[2];
$prevst=$axt[4];
$prevtim=$axt[5];
$trapoid = "1.3.6.1.4.1.41717.30.$t";
$msg = "$ip";
$time=time();
push(@trapoids,$trapoid,OCTET_STRING,$msg);
#@toids=($tra,OCTET_STRING,$message);
#@trapoids=($svSvcName,OCTET_STRING,$msg);
#@oids=$svSvcName,OCTET_STRING, $message);
push (@trapoids,"1.3.6.1.4.1.41717.30.".++$t,OCTET_STRING,"$time");
push (@trapoids,"1.3.6.1.4.1.41717.30.".++$t,OCTET_STRING,"$prevst");
push (@trapoids,"1.3.6.1.4.1.41717.30.".++$t,OCTET_STRING,"$prevtim");
print(TRAPFILE "@trapoids\n");
$t++;
}
#print(TRAPFILE "Sending FAIL trap: @trapoids\n");
my $result = $session->trap(
                            -varbindlist  => \@trapoids
                            #-varbindlist  => [$svSvcName, OCTET_STRING, "$message"]
);

if (!defined($result)) {

    printf("ERROR: %s.\n", $session->error);

    $session->close;
}
}
}
$IP="";
$status="";
}
}

print(TRAPFILE "\n----------\n");
close(TRAPFILE);
