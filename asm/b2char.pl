#!/usr/bin/perl
#/*
# * My RISC-V RV32I CPU
# *   Code Changer from Text Dump to ASCII code for UART Sending
# *    Perl code
# * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
# * @copylight	2021 Yoshiki Kurokawa
# * @license		https://opensource.org/licenses/MIT     MIT license
# * @version		0.1
# */

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


