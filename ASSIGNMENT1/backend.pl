#!/usr/bin/perl 
use Net::SNMP qw(:snmp);
use DBI;
use RRD::Simple;
use FindBin;
use Data::Dumper;
use Net::SNMP::Interfaces;

# Finding the path of db.conf
      my $step =300;my @IF;my $size = 40;

      

      $pwd=$FindBin::Bin;@split=split("/",$pwd);pop(@split);push(@split,"db.conf");$realpath=join("/",@split);
      do "$realpath";

      my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$username , $password);
      $query = $dbh->prepare("SELECT * FROM DEVICES");
      $query->execute() or die $DBI::errstr;
      $query1 = $dbh->prepare("SELECT * FROM DEVICES");
      $query1->execute() or die $DBI::errstr;

      $create=$dbh->prepare("CREATE TABLE IF NOT EXISTS INFO1 (id int(11) NOT NULL,ifnumbers tinytext NOT NULL,name tinytext NOT NULL
                                                                                                                                                                                              
                                                     ) ENGINE=InnoDB DEFAULT CHARSET=latin1  " );
      $create->execute() or die $DBI::errstr;
      
      my %update;
      my @IFN;
      my @sorted;
      my @OIDs;
      my $ID;
      while(my @row=$query->fetchrow_array())
      {
           ($id,$ip,$p,$c)=@row;

            
            my $interfaces = Net::SNMP::Interfaces->new(    Hostname  => $ip,
                                                            Community => $c,
                                                            Port      => $p );
            my @ifnumbers = $interfaces->if_indices();
               @ifnumbers = sort @ifnumbers;
               push @{$IFN[$id]}, @ifnumbers;
      }


     while(my @row=$query1->fetchrow_array())
     {

           ($id,$ip,$p,$c)=@row;
            $ifOperStatus ="1.3.6.1.2.1.2.2.1.8";
	    $ifSpeed="1.3.6.1.2.1.2.2.1.5";
	    $ifType="1.3.6.1.2.1.2.2.1.3";
	    $ifAdminStatus="1.3.6.1.2.1.2.2.1.7";
            @OID;

            foreach(@{$IFN[$id]})
             {
                $oid1="$ifOperStatus.$_";
		$oid2="$ifSpeed.$_";
		$oid3="$ifType.$_";
		$oid4="$ifAdminStatus.$_";
		@oid=($oid1,$oid2,$oid3,$oid4);
                push @OID,@oid;
             }

             @manual;
             $i = 0;

             for( 0..$#OID ) 
             {
       
                       my $row = int( $_ / $size );
                       $manual[$row] = [] unless exists $manual[$row];
                       push @{$manual[$row]}, $OID[$_];
             }

             my ($session, $error) = Net::SNMP->session( -hostname    => $ip,
                                                         -community   => $c,
                                                         -port        => $p,
                                                         -nonblocking => 1,
                                                         -translate   => [-octetstring => 0],
                                                         -maxmsgsize    => 1472,
                                                         -version     => 'snmpv2c',);

            if (!defined $session)
            {
                           printf "ERROR: %s.\n", $error;
                           exit 1;
            }


            for(0..$#manual)
            { 
             my $result = $session->get_request(
                                                -varbindlist        =>  \@{$manual[$_]}, 
                                                -callback           => [ \&c1,$id]);



             if (!defined $result)
                  {
                          printf "ERROR: %s\n", $session->error();
                  }

           snmp_dispatcher();

            }
     }      


      sub c1
      {     
            my ($session,$id) = @_;
            my $list = $session->var_bind_list();
            if (!defined $list)
                 {
                       printf "ERROR: %s\n", $session->error();
                       return;
                 }
            my @names = $session->var_bind_names();
            my $next  = undef;
            my $ifSpeed="1.3.6.1.2.1.2.2.1.5";
            my @array;
            my $ifnumber;
            

#Checking Conditions inorder to filter the interfaces available             

            while (@names)
            {
                my $next = shift @names;
               
		if (oid_base_match($ifSpeed, $next))
			{
				if ($list->{$next} != 0)
					{ 
               
						@array = split(/\./, $next);
						$ifnumber=$array[10];
	
						$oid1="$ifOperStatus.$ifnumber";
						$oid2="$ifType.$ifnumber";
						$oid3="$ifAdminStatus.$ifnumber";
                            
                           
						if ($list->{$oid1}==1 && $list->{$oid2}!=24 && $list->{$oid3}==1)
							{
								push @{$sorted[$id]}, $ifnumber;
							}
					}
			}
	   }
	}




sub c2
      {		
	
            my ($session,$id,$dbh,$ifInOctets,$ifOutOctets,$ifName,@sorted) = @_;
            my $list = $session->var_bind_list();
            my @update;
	    my @Name;
	    my @IF;
		
            if (!defined $list)
            {
                printf "ERROR: %s\n", $session->error();
                return;
            }
	#print "HI\n";
		foreach(@{$sorted[$id]})
             		{
                		$oid1="$ifInOctets.$_";
				$oid2="$ifOutOctets.$_";
				$oid3="$ifName.$_";
                                $in=$list->{$oid1};
                                $out=$list->{$oid2};
                                $name=$list->{$oid3};
				$IN="i"."$_";
				$OUT="o"."$_";
				push @update,"$IN"=>"$in";
				push @update,"$OUT"=>"$out";
				push @Name,"$name/$_";
				push @IF,$_;
                         }

	#	print "@update\n";
	#	print "@Name\n";
	#	print "@IF\n";

 
	my $rrdfile="$pwd/$id.rrd";
	my $rrd = RRD::Simple->new( file => $rrdfile,
         			    cf => [ qw(AVERAGE MAX LAST) ],
                                    default_dstype => "COUNTER",
                                    on_missing_ds => "add",
                                  );
	unless (-f $rrdfile) 
	         {
			$rrd->create( $rrdfile, "mrtg",
			              bytesIn => "COUNTER",
              			      bytesOut => "COUNTER"
                                    );
		 }


	
	$rrd->update(@update);
  
	$IFstring =join(',',@IF);
	$NameString=join(',',@Name);
	$fetch=$dbh->prepare("SELECT COUNT(*) FROM INFO1 WHERE id=$id  "); 
	$fetch->execute()or die $DBI::errstr;
	$row = $fetch->fetchrow_array();
	if($row == 0)
		{
			$dbh->do("INSERT INTO `INFO1` (`id`,`ifnumbers`,`name`)VALUES($id,'$IFstring','$NameString')");
		}       
	if($row == 1)
		{	
			$dbh->do("UPDATE `INFO1` SET  ifnumbers = '$IFstring',name='$NameString'  WHERE id=$id")
		}
  


	}   
                            	

foreach my $i (sort keys @sorted)
	{
		if ($i != 0)
			{
				#print "HII\n";
				$query = $dbh->prepare("SELECT * FROM DEVICES WHERE id=$i");
      				$query->execute() or die $DBI::errstr;
				while(my @row=$query->fetchrow_array())
     					{

           					($id,$ip,$p,$c)=@row;
						#print "@row\n";

						my @OID;
            					$ifInOctets ="1.3.6.1.2.1.2.2.1.10";
	    					$ifOutOctets="1.3.6.1.2.1.2.2.1.16";
						$ifName="1.3.6.1.2.1.31.1.1.1.1";
						
            					foreach(@{$sorted[$i]})
             						{
                						$oid1="$ifInOctets.$_";
								$oid2="$ifOutOctets.$_";
								$oid3="$ifName.$_";
								@oid=($oid1,$oid2,$oid3);
                						push @OID,@oid;
								
             						}
				
             					my ($session, $error) = Net::SNMP->session( -hostname    => $ip,
                                                         -community   => $c,
                                                         -port        => $p,
                                                         -nonblocking => 1,
                                                         -translate   => [-octetstring => 0],
                                                         -maxmsgsize    => 1472,
                                                         -version     => 'snmpv2c',);

            					if (!defined $session)
            						{
                           					printf "ERROR: %s.\n", $error;
                           					exit 1;
            						}
						
						my $result = $session->get_request(
                                                		-varbindlist        =>  \@OID, 
                                                		-callback           => [ \&c2,$id,$dbh,$ifInOctets,$ifOutOctets,$ifName,@sorted]);
						
						snmp_dispatcher();
					}	
			}
	}


