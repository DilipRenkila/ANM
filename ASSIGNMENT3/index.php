<html>
<meta http-equiv= refresh content=10> 
<body><p><a href= redirector.php?>SNMP Trap Manager</a></p>
<style>
table, th, td {
    border: 3px solid black;
}
</style>
<table border = 10>

<?php
$configfile = fopen("../db.conf", "r") or die("Unable to open file!");
eval(fread($configfile,filesize("../db.conf")));
fclose($configfile);
$con=mysqli_connect($host,$username,$password , $database, $port) ;
$result = mysqli_query($con,"SELECT * FROM INFO3"); 
echo "<table border='10'>
<tr>
<th>IP</th>
<th>FQDN</th>
<th>STATUS</th>

</tr>";
while($row = mysqli_fetch_array($result))
{echo "<tr>";
  echo "<td>" . $row['agentaddr'] . "</td>";
  echo "<td>" . $row['FQDN'] . "</td>";
  echo "<td>" . $row['STATUS'] . "</td>";
 echo "</tr>";
  }echo "</table>";

?> 
</table>
</html>
