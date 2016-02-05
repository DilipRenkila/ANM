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
$ip = $_POST['IP'];
$port = $_POST['Port'];
$community = $_POST['Community'];


$DELETE=$_POST['submit'];
if(isset($DELETE))
{

    if($ip=="" | $port=="" | $community=="")
         {
              echo("items can't be empty ");
              exit;
         }
      
    $order = "SELECT * FROM DEVICES WHERE IP='$ip' and PORT='$port' and COMMUNITY='$community'";
                 //declare in the order variable
    
    $result = mysql_query($order);	//order executes
   
    if(mysql_num_rows($result) <=0 )
        {
              echo("DEVICE doesn't exist");
        }
    else
       {
       
              $order = "DELETE FROM DEVICES WHERE IP='$ip' and PORT='$port' and COMMUNITY='$community'";
              
              $result = mysql_query($order);	//order executes
              
              if($result )
               {      
                    echo("Device Deleted");
               }
              else
               {
                   echo("Unable to Delete Device");
               }
 
      }

  
exit;
}
?>
