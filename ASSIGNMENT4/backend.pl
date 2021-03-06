#!/usr/bin/perl

use DBI;
use Net::SNMP;
use Cwd;
use FindBin;
         
       
      my $start_run = time();       
      $pwd=$FindBin::Bin;@split=split("/",$pwd);pop(@split);push(@split,"db.conf");$realpath=join("/",@split);
      do "$realpath";

      my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$username , $password);
      $query = $dbh->prepare("SELECT * FROM DEVICES");
      $query->execute() or die $DBI::errstr;

#creating a table info4 if not exists

         $create=$dbh->prepare("CREATE TABLE IF NOT EXISTS INFO4 ( id int(11) NOT NULL AUTO_INCREMENT,
                                                                  IP tinytext NOT NULL,
                                                                  PORT int(11) NOT NULL,
                                                                  COMMUNITY tinytext NOT NULL,
                                                                  UPTIME tinytext  NOT NULL,
                                                                  Sent_Requests int(11)  NOT NULL,
                                                                  Lost_Requests int(11) NOT NULL ,
                                                                  STATUS int(11) NOT NULL,
                                                                  TIME tinytext NOT NULL,
								  code tinytext NOT NULL,
                                                                  PRIMARY KEY (id) ) 
                                ENGINE=InnoDB DEFAULT CHARSET=latin1  AUTO_INCREMENT=1" );

        $create->execute() or die $DBI::errstr;

#Establishing a SNMP session and sending SNMP requests

         my $OID_SysUptime="1.3.6.1.2.1.1.3.0";

         while(my @row = $query->fetchrow_array)
         { 
           my ($id,$ip,$p,$c) = @row;

           my ($session, $error)= Net::SNMP->session( -hostname    => $ip,
                                                   -community   => $c,
                                                   -port        => $p,
                                                   -nonblocking => 1,
                                                   -version     => 'snmpv2c',
                                                   -timeout     => 5,          );  
            if (!defined $session)
                   {
                         printf "ERROR: %s.\n", $error;
                   }

           my $result = $session->get_request(  -varbindlist    => [ $OID_SysUptime ],
                                             -callback       => [ \&table_callback,$id,$ip,$c,$p,$dbh,$OID_SysUptime ] );

           if (!defined $result)
                  {
                        printf "ERROR: %s\n", $session->error();
                        $session->close();
                  } 
         }


        snmp_dispatcher();          
       





      sub table_callback
      {
               my ($session,$id,$ip,$c,$p,$dbh,$OID_SysUptime) = @_;
               my $result = $session->var_bind_list();
               my ($sent,$lost,$status,@data,$time,$code);
               $sth=$dbh->prepare("SELECT * FROM INFO4 WHERE IP='$ip' and PORT=$p and COMMUNITY='$c'"); 
               $sth->execute()or die $DBI::errstr;
               $fetch=$dbh->prepare("SELECT COUNT(*) FROM INFO4 WHERE IP='$ip' and PORT=$p and COMMUNITY='$c' "); 
               $fetch->execute()or die $DBI::errstr;
               $row = $fetch->fetchrow_array();
               print "$row\n";
               if($row == 0)
	       {	
		    $insert = $dbh->prepare("INSERT INTO INFO4 (`id`,`IP`,`PORT`,`COMMUNITY`,`UPTIME`,`Sent_Requests`,`Lost_Requests`,`STATUS`,`TIME`,`code`)VALUES ( $id, '$ip',$p,'$c','0',0,0,0,'0','0')" );
		    $insert->execute() or die $DBI::errstr;
                    

	       }

$R=$result->{$OID_SysUptime};
print "$R\n";
             
#checking whether device is up or not

               if ($result->{$OID_SysUptime}!=undef) 
               { 
               my ($sent,$lost,$status,@data,$time);

               while(@data=$sth->fetchrow_array())  
                   {
                      $sent=$data[5]+1;
                      $lost=$data[6];
                      $time=localtime();  
                      $code='#FF'.uc(sprintf("%x",255-((1)*8)) x 2);
                  
                  $update=$dbh->prepare("UPDATE `INFO4` SET  UPTIME='$result->{$OID_SysUptime}',Sent_Requests=$sent,Lost_Requests=$lost,STATUS=0,TIME='$time',code='$code'  WHERE IP='$ip' and PORT=$p and COMMUNITY='$c'");
                  $update->execute()or die $DBI::errstr;
               }
               }


              else
              { my ($sent,$lost,$status,@data,$time);

              while(@data=$sth->fetchrow_array())  
                   {
                      $sent=$data[5]+1;
                      $lost=$data[6]+1;
                      $status=$data[7]+1;
                      $time=localtime();
                   $co='#FF'.uc(sprintf("%x",255-(($status)*8)) x 2);

              if ($status>=30)
                   {
                      $status=30;
			$co="#FF0000";
                   }
		        
             $update=$dbh->prepare("UPDATE INFO4 SET  UPTIME = 'DOWN',Sent_Requests=$sent,Lost_Requests=$lost ,STATUS = $status,TIME='$time',code='$co'  WHERE IP='$ip' and PORT=$p and COMMUNITY='$c'");
              
              $update->execute()or die $DBI::errstr;
              } }
            

        }
