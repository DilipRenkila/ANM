<html>
<body>
<table>
<form action="<?php echo $_SERVER['PHP_SELF'];?> " method="POST">
<tr><td><center></br><INPUT type="text" name="ip1" placeholder="IP"/></center></br></td></tr>
<tr><td><center></br><INPUT type="text" name="ip2" placeholder="PORT"/></center></br></td></tr>
<tr><td><center></br><INPUT type="text" name="ip3" placeholder="COMMUNITY"/></center></br></td></tr>
<tr><td><center></br><INPUT type="SUBMIT" name="submit" value="NEXT"/></center></br></td></tr>
</form>
<?php
$configfile = fopen("../db.conf", "r") or die("Unable to open file!");
eval(fread($configfile,filesize("../db.conf")));
fclose($configfile);

$con=mysql_connect($host,$username,$password) or die(mysql_errno(). '='.mysql_error());
$res=mysql_select_db($database) or die(mysql_errno(). '='.mysql_error());
#$rev=mysql_query($data,$con) or die(mysql_errno(). '='.mysql_error());

$sql="CREATE TABLE IF NOT EXISTS `TRAP`( id int(11) NOT NULL AUTO_INCREMENT, IP text NOT NULL, PORT text NOT NULL,COMMUNITY text NOT NULL, PRIMARY KEY (id) )ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1";

$result= mysql_query($sql,$con) or die(mysql_errno(). '='.mysql_error());
if(! $result)
{
 die('Could not create table : ' . mysql_error());
}
if($_POST['ip1'] && $_POST['ip2'] && $_POST['ip3'])
{
$que = mysql_query("SELECT * FROM `TRAP`");
$n = mysql_num_rows($que);
if($n == 0)
{
 $sql="INSERT INTO `TRAP`". "(`IP`,`PORT`,`COMMUNITY`)". "VALUES" . "('$_POST[ip1]', '$_POST[ip2]', '$_POST[ip3]')";
 $result=mysql_query($sql,$con);
}
else
{
  mysql_query("UPDATE `TRAP` SET IP='$_POST[ip1]', PORT='$_POST[ip2]', COMMUNITY='$_POST[ip3]' where id=1",$con);
}
}
?>
</table>
</center>
</body>
</html>
