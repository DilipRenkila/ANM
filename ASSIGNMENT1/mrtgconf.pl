#!/usr/bin/perl -w
use warnings;
use DBI;
use FindBin;

# Finding the path of db.conf
      
 $pwd=$FindBin::Bin;@split=split("/",$pwd);pop(@split);push(@split,"db.conf");$realpath=join("/",@split);
      do "$realpath";

      my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$username , $password);
      $query = $dbh->prepare("SELECT * FROM DEVICES");
      $query->execute() or die $DBI::errstr;
#      system (" sudo mkdir  $pwd/mrtg ");
      system (" sudo mkdir  /var/www/mrtg");

while(my @row=$query->fetchrow_array())
{
($id,$ip,$p,$c)=@row;
$name = "[$c]$ip:$p";
system(" sudo touch /var/www/mrtg/$name.cfg");
system(" sudo cfgmaker  --global \"WorkDir: /var/www/mrtg \" --global \"RunAsDaemon:yes\" --global \"Interval:5\"  $c\@$ip:$p --output=/var/www/mrtg/$name.cfg");
system(" sudo indexmaker /var/www/mrtg/$name.cfg > /var/www/mrtg/index.html"); 
system(" sudo env LANG=C /usr/bin/mrtg /var/www/mrtg/$name.cfg --logging /var/log/mrtg.log ");
}
