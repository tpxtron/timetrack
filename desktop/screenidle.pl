#!/usr/bin/perl
use DateTime;
use POSIX qw(setsid);
$x=`ps -A | grep screenidle.pl`;
$url= "%%URL%%";
$hash= "%%HASH%%";

@lines = split("\n", $x);
$lines =@lines;

if ($lines > 1) {
	$dt = DateTime->now();
	print "[".$dt->datetime()."] *** already running ***\n";
	exit();
}

chdir '/';
umask 0;
open STDIN, '/dev/null';
open STDERR, '>/dev/null';
defined(my $pid = fork);
exit if $pid;
setsid;

$dt = DateTime->now();
print "[".$dt->datetime()."] *** starting ***\n";
#open (LOGFILE, '>>/var/log/screensaver.log');
#print LOGFILE "#[".$dt->datetime()."] *** starting ***\n";
#close (LOGFILE); 
system('curl "'.$url.'?h='.$hash.'&d=starting"');

my $cmd = "dbus-monitor --session \"type='signal',interface='org.gnome.ScreenSaver',member='ActiveChanged'\"";

open (IN, "$cmd |");

while (<IN>) {
	$dt = DateTime->now();
	#open (LOGFILE, '>>/var/log/screensaver.log');
	
	if (m/^\s+boolean true/) {
		system('curl "'.$url.'?h='.$hash.'&d=out"');
		#print LOGFILE "-[".$dt->datetime()."] *** Locked Screen ***\n";
		system("/usr/bin/killall pidgin");
	} elsif (m/^\s+boolean false/) {
		system('curl "'.$url.'?h='.$hash.'&d=in"');
		#print LOGFILE "+[".$dt->datetime()."] *** Unlocked Screen ***\n";
		system("/usr/bin/nohup /usr/local/bin/pidgin &");
	}
	
	#close (LOGFILE); 
}
