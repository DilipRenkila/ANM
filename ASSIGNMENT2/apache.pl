#!/usr/bin/perl
use LWP::Simple;
use DBI;
use Cwd;
use FindBin;
use RRD::Simple;     
   
$pwd=$FindBin::Bin;@split=split("/",$pwd);pop(@split);push(@split,"db.conf");$realpath=join("/",@split);
do "$realpath";

my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$username,$password);
my($cpuload,$uptime, $reqpersec,$bytespersec,$bytesperreq,$cpuUsage,@update);
my $sth = $dbh->prepare("SELECT * FROM LIST WHERE webprobe='1'");
   $sth->execute() or die $DBI::errstr;

while(my @row=$sth->fetchrow_array())
	{
		($id,$ip,$probe)=@row;

		my($url)="http://$ip/server-status?auto";
		my $server_status=get($url);
    
		if (! $server_status) 
			{
				print "Can't access $url\nCheck apache configuration\n\n";
			}

		else 
			{
				$cpuload = $1 if ($server_status =~ /CPULoad:\ ([\d|\.]+)/gi);
				$uptime = $1 if ($server_status =~ /Uptime:\ ([\d|\.]+)/gi);
				$reqpersec = $1 if ($server_status =~ /ReqPerSec:\ ([\d|\.]+)/gi);
				$bytespersec = $1 if ($server_status =~ /BytesPerSec:\ ([\d|\.]+)/gi);
				$bytesperreq = $1 if ($server_status =~ /BytesPerReq:\ ([\d|\.]+)/gi);
				$cpuUsage= $cpuload * $uptime * 0.01;
				push @update,"cpu_usage"=>"$cpuUsage","reqpersec"=>"$reqpersec","bytespersec"=>"$bytespersec", "bytesperreq"=>"$bytesperreq";
				

				my $rrdfile="$pwd/$ip.rrd";
				my $rrd = RRD::Simple->new( file => $rrdfile,
         			    			      cf => [ qw(AVERAGE ) ]
                                                          );


				unless (-f $rrdfile)
					{
						$rrd->create(   $rrdfile, "mrtg",
			              				cpu_usage => "GAUGE",
              			      				reqpersec => "GAUGE",
				     				bytespersec => "GAUGE",
				      				bytesperreq => "GAUGE"
                                    			    );
					}

				$rrd->update(@update);
			}

	}

   
