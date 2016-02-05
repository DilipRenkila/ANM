<html>
<body style="background-color:lightgrey">
<table border="1" style="width: 100%;" CELLPADDING=10 CELLSPACING=1 RULES=ROWS FRAME=HSIDES>

<body style="background-color:white">
<table border="1" style="width: 100%;" CELLPADDING=10 CELLSPACING=1 RULES=ROWS FRAME=HSIDES>
<tr>
<td>
<form action="add2.php" method="POST">
    <i><b>Add devices you want to probe</b>.</i><br><br>
    IP :<br><input type="text" name="IP"placeholder="xxx.xxx.xxx.xxx"><br><br>
    Port :<br><input type="text" name="Port"placeholder="Enter here"><br><br>
    Community :<br><input type="text" name="Community"placeholder="Enter here"><br><br>
   <input type="submit" value="submit" name="submit">    
</form>
</td>
<td>
<form action="display2.php" method="POST">
  <i><b>Details about EXISTING DEVICES</b>.</i><br><br> 
<input type="submit" value="Display" name="Display">
</form>
</td>
<td>
<form action="delete2.php" method="POST">
   <i><b>Delete a device from list of managed devices</b>.</i><br><br>
   IP:<br><input type="text" name="IP"placeholder="xxx.xxx.xxx.xxx"><br><br>
   Port:<br><input type="text" name="Port"placeholder="Enter here"><br><br>
   Community:<br><input type="text" name="Community"placeholder="Enter here"><br><br> 
   <input type="submit" value="submit" name="submit"> 
</form>
</td>
</table>
</body>
</html>


