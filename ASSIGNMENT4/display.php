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
           $conn = mysql_connect($dbhost,$username, $password);
           if(! $conn )
           {
            die('Could not connect: ' . mysql_error());
           }
           mysql_select_db($database);
  
       echo "<body >";
       echo "<table cellpadding=\"5\" border=\"1\">";
       echo "<tr>";
       echo "<th><b>id</b></th>";
       echo "<th><b>IP Address</b></th>";
       echo "<th><b>Port Number</b></th>";
       echo "<th><b>Community</b></th>";
       echo "<th><b>Uptime</b></th>";
       echo "<th><b>sent req</b></th>";
       echo "<th><b>lost req</b></th>";
       echo "<th><b>code</b></th>";
       echo "<th><b>last updated</b></th>";
       echo "</tr>";
       

       $Query = "SELECT * FROM INFO4 ";

       $Query_run = mysql_query($Query,$conn);
       
       while ($Row=mysql_fetch_array($Query_run,MYSQL_ASSOC)) {
       $id = $Row['id'];
       $IP = $Row['IP'];
       $PORT = $Row['PORT'];
       $COMMUNITY=$Row['COMMUNITY'];
       $UPTIME = $Row['UPTIME'];
       $Sent_Requests = $Row['Sent_Requests'];
       $Lost_Requests = $Row['Lost_Requests'];
       $STATUS =$Row['code'];
       $TIME = $Row['TIME']; 

       echo "<meta http-equiv=\"refresh\" content=\"10\">";
       
       echo "<tr>";
       echo "<td><b>$id</b></td>";
       echo "<td><b>$IP </b></td>";
       echo "<td><b>$PORT</b></td>";
       echo "<td><b>$COMMUNITY</b></td>";
       echo "<td><b>$UPTIME</b></td>";
       echo "<td><b>$Sent_Requests</b></td>";
       echo "<td><b>$Lost_Requests</b></td>";
       echo "<td bgcolor=".$STATUS." </td>";
       echo "<td><b>$TIME</b></td>";
       echo "</tr>";
       
                       
      }    

?>
