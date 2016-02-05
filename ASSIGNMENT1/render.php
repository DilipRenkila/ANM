<?php
$NAME=$_GET['name'];
$name=$_GET['NAME'];
$Rrd=$_GET['rrd'];
$i=$_GET['i'];
$o=$_GET['o'];
$ip=$_GET['IP'];
create_graph($NAME, "-1d", "Daily Traffic Analysis for $name",$Rrd,$i,$o);
$graph1 = fopen($NAME,'rb');
header("Content-Type: image/png\n");
header("Content-Transfer-Encoding: binary");
fpassthru($graph1);
unlink($NAME);    
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
