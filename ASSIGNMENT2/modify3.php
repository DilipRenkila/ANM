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
$id = $_POST['ID'];


$graph=$_POST['submit'];

if(isset($graph))
{
     $Query = "SELECT * FROM LIST WHERE ID=$id ";
       $Query_run = mysql_query($Query,$conn);
       
       while ($Row=mysql_fetch_array($Query_run,MYSQL_ASSOC)) 
          {
                    
                    $order = "UPDATE LIST SET webprobe=1  WHERE ID=$id   ";

                    //declare in the order variable
                    $result = mysql_query($order);	//order executes
                     if($result)
                      {echo("Database is updated");}
           }
}



?>

