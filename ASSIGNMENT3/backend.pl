#!/usr/bin/perl
use Net::SNMPTrapd;
use DBI;
use Cwd;
use FindBin;
use Net::SNMP;

$pwd=$FindBin::Bin;@split=split("/",$pwd);pop(@split);push(@split,"db.conf");$realpath=join("/",@split);
do "$realpath";
my $TRAP_FILE = "$pwd/trap.log";
print "$TRAP_FILE\n";
my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$username,$password);
#creating a table info3 if not exists

         $create=$dbh->prepare("CREATE TABLE IF NOT EXISTS INFO3 ( id int(11) NOT NULL AUTO_INCREMENT,
                                                                  time tinytext NOT NULL,
                                                                  agentaddr tinytext NOT NULL,
                                                                  ent_OID tinytext NOT NULL,
                                                                  ptime tinytext NOT NULL,
                                                                  pSTATUS tinytext NOT NULL,
                                                                  FQDN tinytext NOT NULL,
                                                                  STATUS tinytext NOT NULL,
                                                                  PRIMARY KEY (id) ) 
                                ENGINE=InnoDB DEFAULT CHARSET=latin1  AUTO_INCREMENT=1" );

        $create->execute() or die $DBI::errstr;



my $snmptrapd= Net::SNMPTrapd->new( -LocalPort => 50162, -timeout   => 1  )
                                    or die "Error creating SNMPTrapd listener: ", Net::SNMPTrapd->error;
while (1){

    my $trap = $snmptrapd->get_trap();

    if (!defined ($trap))
    {
       printf "$0:%s\n",Net::SNMPTrapd->error;
       exit 1;
    }
    elsif ($trap == 0)
    {
          next
    }

    if (!defined($trap->process_trap())) 
    {
       
       printf "$0: %s\n", Net::SNMPTrapd->error

    } 

    else 
    {

                  $remoteaddr=$trap->remoteaddr; 
                  $remoteport=$trap->remoteport; 
                  $version=$trap->version;
                  $community=$trap->community;
                  $agentaddr=$trap->agentaddr();
                  $pdu_type=$trap->pdu_type([1]);
                  $ent_OID=$trap->ent_OID();
                  $generic_trap=$trap->generic_trap([1]);
                  $specific_trap=$trap->specific_trap();
                  $timeticks=$trap->timeticks();
                  $request_ID=$trap->request_ID();
                  $error_status=$trap->error_status();
                  $error_index=$trap->error_index();
                  my @varbind = qw();
		  my @varbindlist= qw();
                  for my $vals (@{$trap->varbinds}) 
                         {  
                               for (keys(%{$vals}))
                                       {
                                                  $varbinds= $_; $OID_value=$vals->{$_};
				                  push (@varbindlist, $varbinds, OCTET_STRING, $OID_value);

                                        }
                          }

my $STATUS=$varbindlist[5];
my $varbind1=$varbindlist[0];
my $varbind2=$varbindlist[3];
my $FQDN = $varbindlist[2];
my $time=time;
my $date=localtime();
my $host="Localhost";
#open(TRAPFILE, ">> $TRAP_FILE");
open TRAPFILE, ">>$TRAP_FILE"  or die $!;
print "AAAAAAAAAAAAAA\n";
print(TRAPFILE "New trap received: $date for \nHOST: $host\nIP: $agentaddr\n");
print(TRAPFILE "STATUS: $STATUS\n");
print(TRAPFILE "FQDN: $FQDN\n");
print(TRAPFILE "----------------------------------------------------------------------\n");
close TRAPFILE;
               $sth=$dbh->prepare("SELECT * FROM INFO3 WHERE agentaddr='$agentaddr'"); 
               $sth->execute()or die $DBI::errstr;
               $fetch=$dbh->prepare("SELECT COUNT(*) FROM INFO3 WHERE agentaddr='$agentaddr'  "); 
               $fetch->execute()or die $DBI::errstr;
               $row = $fetch->fetchrow_array();
               if($row == 0)
	       {	
          		$dbh->do("INSERT INTO INFO3(`id`,`time`,`agentaddr`,`ent_OID`,`ptime`,`pSTATUS`,`FQDN`,`STATUS`)VALUES                               

               (  NULL,
                 '$time',
                 '$agentaddr',
                 '$ent_OID',
                 '$ptime',
                 '$pSTATUS',
                 '$FQDN',
                 '$STATUS'
                               )"       );

	       }
		else
		{
			while(@data=$sth->fetchrow_array())  
                   		{
                      			$ptime=$data[1];
                      			$pSTATUS=$data[7];
                      			$time=time; 
					$dbh->do("UPDATE `INFO3` SET  time='$time',ptime='$ptime',pSTATUS='$pSTATUS',STATUS='$STATUS',FQDN='$FQDN' WHERE agentaddr='$agentaddr' ");                               


				}
 
		}

$query = $dbh->prepare("SELECT * FROM INFO3 WHERE STATUS='3'");
$query->execute() or die $DBI::errstr;

my @varbinds2=qw();
while(my @data = $query->fetchrow_array)
	{  	
		$ptime=$data[4];
		$pSTATUS=$data[5];
                $time=$data[1];
		$fqdn=$data[6];
		print "$fqdn\n"; 
		$OID= '1.3.6.1.4.1.41717.20.1';
		@varbinds=($OID,OCTET_STRING,$fqdn);
		push(@varbinds,"1.3.6.1.4.1.41717.20.2",OCTET_STRING,"$time");
		push(@varbinds,"1.3.6.1.4.1.41717.20.3",OCTET_STRING,"$pSTATUS");
		push(@varbinds,"1.3.6.1.4.1.41717.20.4",OCTET_STRING,"$ptime");

		$query1 = $dbh->prepare("SELECT * FROM TRAP");
		$query1->execute() or die $DBI::errstr;  
 
   		while(my @row = $query1->fetchrow_array)
			{ 
				my ($id,$ip,$p,$c) = @row;
				my ($session, $error)= Net::SNMP->session(       -hostname    => $ip,
		                                                                 -community   => $c,
                  		                                                 -port        => $p,
                                    		                                 -version     => 1  ); 
				if (!defined $session)
					{
						printf "ERROR: %s.\n", $error;
					}  

				$result = $session->trap ( -varbindlist      => \@varbinds   );

				if (! $result)
					{
						print "An error occurred sending the trap: " . $session->error();
					}

			}     
	}    
	
$query = $dbh->prepare("SELECT * FROM INFO3 WHERE STATUS='2'");
$query->execute() or die $DBI::errstr;
$query2 = $dbh->prepare("SELECT COUNT(*) FROM INFO3 WHERE STATUS='2'");
$query2->execute() or die $DBI::errstr;
$r = $query2->fetchrow_array();
$d=1;
while(my @data = $query->fetchrow_array)
	{
		 
		$ptime=$data[4];
		$pSTATUS=$data[5];
                $time=$data[1];
		$fqdn=$data[6]; 
		print "$fqdn\n"; 
		$OID2= "1.3.6.1.4.1.41717.30.$d";
		push(@varbinds2,$OID2,OCTET_STRING,$fqdn);
		push(@varbinds2,"1.3.6.1.4.1.41717.30.".++$d,OCTET_STRING,"$time");
		push(@varbinds2,"1.3.6.1.4.1.41717.30.".++$d,OCTET_STRING,"$pSTATUS");
		push(@varbinds2,"1.3.6.1.4.1.41717.30.".++$d,OCTET_STRING,"$ptime");
		$d++;
#print "@varbinds2\n";
$t=($d-1)/4;
print "@varbinds2\n";
if($t==$r)
{
		$query1 = $dbh->prepare("SELECT * FROM TRAP");
		$query1->execute() or die $DBI::errstr;  
 		print "HI\n";
   		while(my @row = $query1->fetchrow_array)
			{ 

				my ($id,$ip,$p,$c) = @row;
				my ($session, $error)= Net::SNMP->session(       -hostname    => $ip,
		                                                                 -community   => $c,
                  		                                                 -port        => $p,
                                    		                                 -version     => 1  ); 
				if (!defined $session)
					{
						printf "ERROR: %s.\n", $error;
					}  

				$result = $session->trap ( -varbindlist      => \@varbinds2   );

				if (! $result)
					{
						print "An error occurred sending the trap: " . $session->error();
					}

			}     
	   
	
	}


}



    }

}
