#!/usr/bin/perl

use Getopt::Long;

GetOptions('v' => \$v);


while(<>) {

	chop;
	for($i = 0;  $i < length($_); $i++) {
		$c = substr($_, $i, 1);
		$ch = ord($c);
		printf "%02x ",$ch;
	}
	print "\n";

}


