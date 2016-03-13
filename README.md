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
$ sudo apt-get -y install apache2 mysql-server php5 php5-mysql libgd-graph-perl libapache2-mod-php5 cpanminus openssh-server
$ sudo cpan install DBI
$ sudo cpan install Net::OpenSSH
```
