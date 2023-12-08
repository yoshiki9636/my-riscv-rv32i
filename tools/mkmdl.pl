#!/usr/bin/perl

#/*
# * My RISC-V RV32I CPU
# *   Verilog Upper Module Definition Creator
# *    Perl code
# * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
# * @copylight	2021 Yoshiki Kurokawa
# * @license		https://opensource.org/licenses/MIT     MIT license
# * @version		0.1
# */

$flg = 0;

while(<>) {
	s/reg//g;
	s/wire//g;
	if ((flg == 0)&&(/^module\s+(\S+)\s*\(/)) {
		$flg = 1;
		print "$1 $1 (\n";
	}
	elsif (($flg > 0)&&(/^\s*(input|output)\s+signed\s+(\[\d+:\d+\])\s+(\w+)\s*/)) {
		if ($flg == 1) {
			$flg = 2;
			print "	";
		}
		else {
			print ",\n	";
		}
		print ".$3($3)";
	}
	elsif (($flg > 0)&&(/^\s*(input|output)\s+(\[\d+:\d+\])\s+(\w+)\s*/)) {
		if ($flg == 1) {
			$flg = 2;
			print "	";
		}
		else {
			print ",\n	";
		}
		print ".$3($3)";
	}
	elsif (($flg > 0)&&(/^\s*(input|output)\s+(\w+)\s*/)) {
		if ($flg == 1) {
			$flg = 2;
			print "	";
		}
		else {
			print ",\n	";
		}
		print ".$2($2)";
	}
	elsif (($flg > 0)&&(/\s*\)\;\s*$/)) {
		$flg = -1;
		print "\n	);\n";
	}
}


