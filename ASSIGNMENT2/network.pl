#!/usr/bin/perl 
use Net::SNMP qw(:snmp);
use DBI;
use Cwd;
use FindBin;
use RRD::Simple;
use Data::Dumper;
my $ifInOctets="1.3.6.1.2.1.2.2.1.10";
my $ifOutOctets="1.3.6.1.2.1.2.2.1.16";
my @oids;
my $size=50;

$pwd=$FindBin::Bin;@split=split("/",$pwd);pop(@split);push(@split,"db.conf");$realpath=join("/",@split);
do "$realpath";

my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$username,$password);
my $sth = $dbh->prepare("SELECT * FROM LIST where probe=1");
   $sth->execute() or die $DBI::errstr;
my $sth1 = $dbh->prepare("SELECT * FROM LIST where probe=2");
   $sth1->execute() or die $DBI::errstr;


while(my @row=$sth->fetchrow_array())
	{
		($id,$ip,$p,$c,$Interfaces,$n,$probe)=@row;
		@manual;
                 $i = 0;


                 my ($session, $error) = Net::SNMP->session( -hostname    => $ip,
                                                             -community   => $c,
                                                             -port        => $p,
                                                             -nonblocking => 1,
                                                             -maxmsgsize  => 1472,
                                                             -translate   => [-octetstring => 0],
                                                             -version     => 'snmpv2c'                 );

                  if (!defined $session)
                        {
                                printf "ERROR: %s.\n", $error;
                                exit 1;
                        }


		@split=split(",",$n);
		foreach(@split)
			{
				$oid1="$ifInOctets.$_";             
				$oid2="$ifOutOctets.$_";
				push (@oids,$oid1);
				push (@oids,$oid2);
			}
             
		for( 0..$#oids ) 
			{
				my $row = int( $_ / $size );
				$manual[$row] = [] unless exists $manual[$row];
				push @{$manual[$row]}, $oids[$_];
			}

		for(0..$#manual)
			{ 
				my $result = $session->get_request(-varbindlist    => \@{$manual[$_]}, 
                                                                    -callback       => [ \&c1,$id,@oids ]);

				if (!defined $result)
					{
						printf "ERROR: %s\n", $session->error();
					}
				snmp_dispatcher();           
			}
	}
           

while(my @row=$sth1->fetchrow_array())
	{
		($id,$ip,$p,$c,$Interfaces,$n,$probe)=@row;
	#	print "@row\n";
		@manual;
                 $i = 0;


                 my ($session, $error) = Net::SNMP->session( -hostname    => $ip,
                                                             -community   => $c,
                                                             -port        => $p,
                                                             -nonblocking => 1,
                                                             -maxmsgsize  => 1472,
                                                             -translate   => [-octetstring => 0],
                                                             -version     => 'snmpv2c'                 );

                  if (!defined $session)
                        {
                                printf "ERROR: %s.\n", $error;
                                exit 1;
                        }


		@split=split(",",$Interfaces);
		foreach(@split)
			{
				$oid1="$ifInOctets.$_";             
				$oid2="$ifOutOctets.$_";
				push (@oids,$oid1);
				push (@oids,$oid2);
			}
             
		for( 0..$#oids ) 
			{
				my $row = int( $_ / $size );
				$manual[$row] = [] unless exists $manual[$row];
				push @{$manual[$row]}, $oids[$_];
			}

		for(0..$#manual)
			{ 
				my $result = $session->get_request(-varbindlist    => \@{$manual[$_]}, 
                                                                    -callback       => [ \&c2,$id,@oids ]);

				if (!defined $result)
					{
						printf "ERROR: %s\n", $session->error();
					}
				snmp_dispatcher();           
			}
	}
           






       

sub c1
	{
		my ($session,$id,@oids) = @_; 
		my $in;
		my $out;
		my @update;           
		my $list = $session->var_bind_list();
		my $ifInOctets="1.3.6.1.2.1.2.2.1.10";

		if (!defined $list)
			{
				printf "ERROR: %s\n", $session->error();
				return;
			}

           
                 
		foreach(@oids)
			{

				if(oid_base_match($ifInOctets, $_))
					{
						$in=$list->{$_};
						@array = split(/\./, $_);
						$ifnumber=$array[10];
						$IN="i"."$ifnumber";
$in=$in/4;

						push @update,"$IN"=>"$in"; 
                                     
					}   
                             
				else
					{
						$out=$list->{$_};
						@array = split(/\./, $_);
						$ifnumber=$array[10]; 
						$OUT="o"."$ifnumber";

$out=$out/4;       
						push @update, "$OUT"=>"$out";
					}
                         
           
			}

		my $rrdfile="$pwd/$id.rrd";
		my $rrd = RRD::Simple->new( 	file => $rrdfile,
         			    		cf => [ qw(AVERAGE) ],
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
		#print @update;
		$rrd->update(@update);

	}

	                           

sub c2
	{
		my ($session,$id,@oids) = @_; 
		my $in = 0;
		my $out= 0;
		my $IN;
		my $OUT;
		my @update;           
		my $list = $session->var_bind_list();
		my $ifInOctets="1.3.6.1.2.1.2.2.1.10";
	#	my $d="AGGREGATE"; 
		if (!defined $list)
			{
				printf "ERROR: %s\n", $session->error();
				return;
			}

           
                 
		foreach(@oids)
			{

				if(oid_base_match($ifInOctets, $_))
					{
						$in=$in + $list->{$_};

 
                                     
					}   
                             
				else
					{
						$out=$out + $list->{$_};


					}
                         
           
			}
$in=$in/4;
$out=$out/4;
		print "$in,$out\n";
						 $IN="iAGGREGATE";
						 $OUT="oAGGREGATE";
						push @update,"$IN"=>"$in";       
						push @update, "$OUT"=>"$out";

		my $rrdfile="$pwd/$id.rrd";
		my $rrd = RRD::Simple->new( 	file => $rrdfile,
         			    		cf => [ qw(AVERAGE) ],
                                    		default_dstype => "COUNTER",
                                    		on_missing_ds => "add",
                                  	   );
		unless (-f $rrdfile)
			{
				$rrd->create( $rrdfile, "mrtg",
			              	      iAGGREGATE => "COUNTER",
              			      	      oAGGREGATE => "COUNTER"
                                    	    );
		 	}
		print Dumper(@update);
		$rrd->update(@update);

	}

	                           








