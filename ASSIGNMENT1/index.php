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


// Get values from form 

       $Query = "SELECT * FROM INFO1  ";
       $Query_run = mysql_query($Query,$conn);
       $Query1 = "SELECT * FROM DEVICES";
       $Query_run1 = mysql_query($Query1,$conn);
       
       while (($Row=mysql_fetch_array($Query_run,MYSQL_ASSOC)) && ($row=mysql_fetch_array($Query_run1,MYSQL_ASSOC))) 
          {
                       $id=$Row['id'];
                       $q=$Row['ifnumbers'];
                       $r=$Row['name'];
                       $d = explode(",",$q);
                       $t = explode(",",$r);
		       $ip=$row['IP'];
foreach (array_combine($d, $t) as $n => $name){

                       $o="o"."$n";
                       $i="i"."$n";
		       $NAME=rand(); 
		       $NAME="${NAME}.png";
			$rrd="$id.rrd";
#                       create_graph($NAME, "-1d", "Daily Traffic Analysis for $name of $ip","$id.rrd",$i,$o); 
		   

                       echo "<table>";
                       echo "<tr><td>";
 		       echo "<b>5min Daily Avg graph for $name of $ip<br>";
                       echo"<br><img src='render.php?name=$NAME&NAME=$name&ip=$ip&rrd=$rrd&i=$i&o=$o'/><br>";
                       echo "</td></tr>";
                       echo "</table>";
	#		unlink($NAME);
         }


}




function create_graph($output,$start,$title,$rrd,$i,$o)
       {
           $options = array(
                              "--slope-mode",
                              '--end',"now",
	                      '--start',"now-84600",'--alt-y-grid','--alt-autoscale','--rigid',
                              "--title=$title",
                              "--vertical-label=bytes/sec",
                              "--lower=0",
			      "--units=si",
                              "--force-rules-legend",
                              "DEF:i=$rrd:$i:AVERAGE",
                              "DEF:o=$rrd:$o:AVERAGE",
                              "AREA:i#0000FF:IN bytes per sec", 
                              "LINE2:o#FF0000:OUT bytes per sec\l",
                              "GPRINT:i:AVERAGE:IN  AVG %6.2lf %SBps\l",
                              "GPRINT:o:AVERAGE:OUT AVG %6.2lf %SBps\l",
                              "GPRINT:i:MAX:IN  MAX %6.2lf %SBps\l",
                              "GPRINT:o:MAX:OUT MAX %6.2lf %SBps\l",
                              "GPRINT:i:LAST:IN  LAST %6.2lf %SBps\l",
                              "GPRINT:o:LAST:OUT LAST %6.2lf %SBps\l"
                                                        );

           $ret = rrd_graph($output, $options);
           if (! $ret) 
                         {
                              echo "<b>Graph error: </b>".rrd_error()."\n";
                         }
     
       }


?>



