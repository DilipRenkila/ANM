#!/usr/bin/perl 
use Net::SNMP::Interfaces;
use DBI;
use Cwd;
use FindBin;
use LWP::Simple;

$pwd=$FindBin::Bin;@split=split("/",$pwd);pop(@split);push(@split,"db.conf");$realpath=join("/",@split);
do "$realpath";

my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$username,$password);
my $sth = $dbh->prepare("SELECT * FROM DEVICES");
   $sth->execute() or die $DBI::errstr;
 
$dbh->do("CREATE TABLE IF NOT EXISTS LIST (   id int(11) NOT NULL ,
                                              IP tinytext NOT NULL,
                                              PORT int(11) NOT NULL,
                                              COMMUNITY tinytext NOT NULL,
                                              INTERFACES tinytext  NOT NULL,
                                              Wanted tinytext  NOT NULL,
					      probe int(11) NOT NULL,
					      webprobe int(11) NOT NULL
                                              
                                              
                                              ) ENGINE=InnoDB DEFAULT CHARSET=latin1 ");

while(my @row=$sth->fetchrow_array())
	{
		($id,$ip,$p,$c)=@row;
		my $w;
		my $interfaces = Net::SNMP::Interfaces->new(    Hostname  => $ip,
                                                                Community => $c,
                                                                Port      => $p );
		my @ifnumbers = $interfaces->if_indices();
		@ifnumbers = sort @ifnumbers;
		$string =join(',',@ifnumbers);

		$fetch=$dbh->prepare("SELECT COUNT(*) FROM LIST WHERE id=$id "); 
		$fetch->execute()or die $DBI::errstr;
		$row = $fetch->fetchrow_array();
		if($row == 0)
			{
				$dbh->do("INSERT INTO LIST (`id`,`IP`,`PORT`,`COMMUNITY`,`INTERFACES`,`Wanted`,`probe`,`webprobe`)VALUES($id,'$ip',$p,'$c','$string','NONE',0,0)");
			}       
	}



