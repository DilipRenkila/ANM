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

$conn = mysql_connect($dbhost, $username,$password);
if(! $conn )
{
  die('Could not connect: ' . mysql_error());
}
mysql_select_db($database);

// Get values from form 
$DISPLAY=$_POST['Display'];
       echo "<body >";
       echo "<table cellpadding=\"5\" border=\"1\">";
       echo "<tr>";
       echo "<th><b>id</b></th>";
       echo "<th><b>IP Address</b></th>";
       echo "<th><b>Port Number</b></th>";
       echo "<th><b>Community</b></th>";
if (isset($DISPLAY) )
{
  mysql_select_db("$database",$conn);
  $Query = "SELECT * FROM DEVICES ";
  $Query_run = mysql_query($Query,$conn);
       
       while ($Row=mysql_fetch_array($Query_run,MYSQL_ASSOC)) {

       $id = $Row['id'];
       $IP = $Row['IP'];
       $PORT = $Row['PORT'];
       $COMMUNITY=$Row['COMMUNITY'];
       

       
       echo "</tr>";
       echo "<tr>";
       echo "<td><b>$id</b></td>";
       echo "<td><b>$IP </b></td>";
       echo "<td><b>$PORT</b></td>";
       echo "<td><b>$COMMUNITY</b></td>";
     
       echo "</tr>";
 #      echo "</table>";
       echo "</body>";
                                                              
      
}
}
?>
<html>
<body style="background-color:lightgrey">
<table border="1" style="width: 100%;" CELLPADDING=10 CELLSPACING=1 RULES=ROWS FRAME=HSIDES>
<tr>
<td>
<form action="graph.php" method="POST">
   <i><b>enter the Details of the device for which you want to graphs</b>.</i><br><br>
    ID :<br><input type="text" name="ID"><br><br>
    <input type="submit" value="submit" name="submit"> 
</form>
</td>
</table>
</body>
</html>


 
