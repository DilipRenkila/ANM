use DBI;
my $dbh = DBI->connect("dbi:mysql:", "root","1");
$dbh->do("create database ANM");
$dbh->do( "use ANM" );
$dbh->do("CREATE TABLE IF NOT EXISTS DEVICES (id int(11) NOT NULL AUTO_INCREMENT,IP tinytext NOT NULL,PORT int(11) NOT NULL,COMMUNITY tinytext NOT NULL,PRIMARY KEY (id)
                                                                                                                                                                                                                                             ) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 " );
$dbh->do("INSERT INTO DEVICES (`id`,`IP`,`PORT`,`COMMUNITY`)VALUES ( NULL, 'demo.snmplabs.com',161,'public')" );
