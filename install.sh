#!/bin/sh
set -o xtrace
sudo apt-get install snmp snmpd mysql-server rrdtool mrtg librrds-perl apache2 php5 libapache2-mod-php5 php5-rrd php5-mysql
sudo /etc/init.d/apache2 restart
perl -MCPAN -e 'install LWP::Simple'
perl -MCPAN -e 'install Net::SNMP'
perl -MCPAN -e 'install Net::SNMP::Interfaces'
perl -MCPAN -e 'install RRD::Simple'
perl -MCPAN -e 'install RRD::Editor'

