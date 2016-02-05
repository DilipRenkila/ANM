<?php
ini_set('display_errors',1);
$background_color = "Green";
$path = dirname(__FILE__);
$path1 = explode("/",$path,-1);
$path1[count($path1)+1]='db.conf';
$finalpath = implode("/",$path1);
$handle = fopen($finalpath, "r");
$hostname;$port;$username;$password;$database;
while (!feof($handle))
{
  $line = fgets($handle);
  $data = explode("\"",$line);
    if($data[0]=='$hostname=')
    {
      $hostname= $data[1];      
    }
    elseif($data[0]=='$port=')
    {
     $port= $data[1];
    }
    elseif($data[0]=='$username=')
    {
     $username= $data[1];
    }
    elseif($data[0]=='$password=')
    {
     $password= $data[1];
    }
    elseif($data[0]=='$database=')
    {
     $database= $data[1];
    }
 }
// Creating  mysql connection
$dbhost="$hostname:$port";

$conn = mysql_connect($dbhost,$username,$password);
if(! $conn )
{
  die('Could not connect: ' . mysql_error());
}
mysql_select_db($database);


/// Get values from form 
$id = $_POST['ID'];
$ID = $_POST['id'];
#$graph=$_POST['network'];
#$webserver=$_POST['webserver'];

$both=$_POST['plot'];


if(isset($both))
{ 
       $Query = "SELECT * FROM LIST WHERE id=$id ";
       $Query_run = mysql_query($Query,$conn);
       $Query1 = "SELECT * FROM LIST WHERE id=$ID ";
       $Query_run1 = mysql_query($Query1,$conn);       
       while (($Row=mysql_fetch_array($Query_run,MYSQL_ASSOC)) && ($row=mysql_fetch_array($Query_run1,MYSQL_ASSOC))) 
          {                      
			         $q=$Row['Wanted'];
                    		 $IP=$Row['IP'];
                                 $ip=$row['IP'];
			         $d = explode(",",$q);
			         foreach ($d as $n)
			         {
                                     $o="o"."$n";
                                     $i="i"."$n";
				     
                       create_graphS("$id-$ip (day).png", "-1d", " $n of $IP and for webserver $ip","$id.rrd","$ip.rrd",$i,$o); 

                       echo "<table>";
                       echo "<tr><td>";
                       echo "<img src='$id-$ip (day).png' alt='Generated RRD image'>";
                       echo "</td></tr>";
                       echo "</table>";
                       }

		  }
}
function create_graphS($output,$start,$title,$rrd1,$rrd2,$i,$o)
       {
           $options = array(
                              "--slope-mode",
                              '--end',"now",
	                      '--start',"now-84600",'--alt-y-grid','--alt-autoscale','--rigid',
                              "--title=$title",
 #                             "--vertical-label=bytes/sec",
                              "--lower=0",
			      "--units=si",
                              "--force-rules-legend",
                              "DEF:I=$rrd1:$i:AVERAGE",
                              "DEF:O=$rrd1:$o:AVERAGE",
                              "DEF:c=$rrd2:cpu_usage:AVERAGE",
                              "DEF:r=$rrd2:reqpersec:AVERAGE",
			      "DEF:b=$rrd2:bytespersec:AVERAGE",
			      "DEF:q=$rrd2:bytesperreq:AVERAGE",
                              "CDEF:i=I,4,*",
                              "CDEF:o=O,4,*",
                              "AREA:i#0000FF:IN bytes per sec\l", 
                              "LINE2:o#FF0000:OUT bytes per sec\l",
                              "LINE3:c#0000FF:Cpu Usage of webserver\l", 
                              "LINE4:r#FF0000:Requests per second of webserver\l",
			      "LINE5:b#F0000F:Bytes per second of webserver\l",
			      "LINE6:q#F000F0:Bytes per Request of webserver\l",
                              "GPRINT:i:AVERAGE:IN  AVG %6.2lf %SBps\l",
                              "GPRINT:o:AVERAGE:OUT AVG %6.2lf %SBps\l",
                              "GPRINT:i:MAX:IN  MAX %6.2lf %SBps\l",
                              "GPRINT:o:MAX:OUT MAX %6.2lf %SBps\l",
                              "GPRINT:i:LAST:IN  LAST %6.2lf %SBps\l",
                              "GPRINT:o:LAST:OUT LAST %6.2lf %SBps\l",
                              "GPRINT:c:AVERAGE:Cpu Usage AVG %6.2lf \l",
                              "GPRINT:c:MAX:Cpu Usage MAX %6.2lf \l",
                              "GPRINT:c:LAST:Cpu Usage LAST %6.2lf \l",
                              "GPRINT:r:AVERAGE:Requests per second AVG %6.2lf \l",
                              "GPRINT:r:MAX:Requests per second MAX %6.2lf \l",
                              "GPRINT:r:LAST:Requests per second LAST %6.2lf \l",
                              "GPRINT:b:AVERAGE:Bytes per Second AVG %6.2lf %SBps\l",
                              "GPRINT:b:MAX:Bytes per Second MAX %6.2lf %SBps\l",
                              "GPRINT:b:LAST:Bytes per Second LAST %6.2lf %SBps\l",
                              "GPRINT:q:AVERAGE:Bytes per Request AVG %6.2lf \l",
                              "GPRINT:q:MAX:Bytes per Request MAX %6.2lf \l",
                              "GPRINT:q:LAST:Bytes per Request LAST %6.2lf \l"
                                                        );

           $ret = rrd_graph($output, $options);
           if (! $ret) 
                         {
                              echo "<b>Graph error: </b>".rrd_error()."\n";
                         }
     
       }






?>



