#!/usr/bin/perl
#/*
# * My RISC-V RV32I CPU
# *   Verilog Upper Module Signal Definition Creator
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
	if ((flg == 0)&&(/^module\s+(\S+)\s*/)) {
		$flg = 1;
	}
	elsif (($flg > 0)&&(/^\s*(input|output|inout)\s+signed\s+(\[[\w-+]+:[\w-+]+\])\s+(\w+)\s*/)) {
		print "wire signed $2 $3; // $1\n";
	}
	elsif (($flg > 0)&&(/^\s*(input|output|inout)\s+(\[[\w-+]+:[\w-+]+\])\s+(\w+)\s*/)) {
		print "wire $2 $3; // $1\n";
	}
	elsif (($flg > 0)&&(/^\s*(input|output|inout)\s+(\w+)\s*/)) {
		print "wire $2; // $1\n";
	}
	        elsif (($flg > 0)&&(/\s*\)\;\s*$/)) {
                $flg = 0;
        }
}


