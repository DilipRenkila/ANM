# ANM
An Advanced Network Management Tool for managing your complex Networks through ainteractive web dashboard. This is based up on Simple Network Management Protocol.

The basic functions of this tool is to

- visualize bitrate of the devices being monitored graphically through a dashboard. 

- correlate the performance of your network devices and webservers visually. 

- manage traps that are being sent to manager based upon their severity.
 
- manage the current state of monitored devices.

##Requirements

The packages required can be installed by the following.

```sh
sudo apt-get install snmp snmpd mysql-server rrdtool mrtg librrds-perl apache2 php5 libapache2-mod-php5 php5-rrd php5-mysql
sudo /etc/init.d/apache2 restart
perl -MCPAN -e 'install LWP::Simple'
perl -MCPAN -e 'install Net::SNMP'
perl -MCPAN -e 'install Net::SNMP::Interfaces'
perl -MCPAN -e 'install RRD::Simple'
perl -MCPAN -e 'install RRD::Editor'
```
##Getting Started

Before proceeding to installation, please change the login credentials in "db.conf" file.

```perl
$hostname="<your_ip>";
$port="<port_mysql>";
$database="<mysql_database_name>";
$username="<mysql_username>";
$password="<mysql_password>";
```

##Installation

To automatically install the tool along with all the pre-requisites, Just run the ````install.sh```` script using the following command from your tool directory

```sh
./install.sh
```
