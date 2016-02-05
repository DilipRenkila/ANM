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

$conn = mysql_connect($dbhost, $username, $password);
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
       echo "<th><b>IP</b></th>";
       echo "<th><b>PORT</b></th>";
       echo "<th><b>COMMUNITY</b></th>";
       echo "<th><b>List of Interfaces</b></th>";
       echo "<th><b>probed Interfaces</b></th>";
       echo "<th><b>webserver</b></th>";
       echo "</tr>";
      






if (isset($DISPLAY) )
{
  mysql_select_db("$database",$conn);
  $Query = "SELECT * FROM LIST ";
  $Query_run = mysql_query($Query,$conn);
       
       while ($Row=mysql_fetch_array($Query_run,MYSQL_ASSOC)) {

       $id = $Row['id'];
       $IP = $Row['IP'];
       $PORT = $Row['PORT'];
       $COMMUNITY=$Row['COMMUNITY'];
       $probe=$Row['probe'];
       $ifnumber=$Row['Wanted'];
       $ifnumbers=$Row['INTERFACES'];
       $webprobe=$Row['webprobe'];
       echo "<tr>";
       echo "<td><b>$id</b></td>";
       echo "<td><b>$IP </b></td>";
       echo "<td><b>$PORT</b></td>";
       echo "<td><b>$COMMUNITY</b></td>";
       echo "<td><b>$ifnumbers</b></td>";
       echo "<td><b>$ifnumber</b></td>";
       echo "<td><b>$webprobe</b></td>";
       echo "</tr>";
  #     echo "</table>";
       echo "</body>";
                                                              
      
}
}
?>


<html>
<body style="background-color:lightgrey">
<table border="1" style="width: 100%;" CELLPADDING=10 CELLSPACING=1 RULES=ROWS FRAME=HSIDES>
<tr>
<td>
<form action="modify2.php" method="POST">
    <i><b>Enter the details of device interface which you want to probe      (if you want to probe for  aggregate statistics enter '0' in IF_NUMBER field)  </b>.</i><br><br>
    ID :<br><input type="text" name="ID"><br><br>
    IF_NUMBER :<br><input type="text" name="IF_NUMBER"><br><br>
   <input type="submit" value="submit" name="submit">    
</form>
</tr>
</td>
<tr>
<td>
<form action="modify3.php" method="POST">
    <i><b>Enter the details of device for which you want to probe webserver statistics  </b>.</i><br><br>
    ID :<br><input type="text" name="ID"><br><br>
    
   <input type="submit" value="submit" name="submit">    
</form>
</tr>
</td>
<tr>
<td>
<form action="graph2.php" method="POST">
    <i><b> Press Submit if you want the graphs </b>.</i><br><br>
	ID of Network Device :<br><input type="text" name="ID"><br><br>
        ID of webserver :<br><input type="text" name="id"><br><br>
   <input type="submit" value="plot" name="plot">    

</tr>
</td>
</table>
</body>
</html>




 
