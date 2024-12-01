#!/usr/bin/perl
#/*
# * My RISC-V RV32I CPU
# *   Code Changer from Text Dump to ASCII code for UART Sending
# *    Perl code
# * @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
# * @copylight	2023 Yoshiki Kurokawa
# * @license		https://opensource.org/licenses/MIT     MIT license
# * @version		0.1
# */

$adr = 0;
while(<>) {

	printf "%08x ",$adr;
	print;
	$adr += 1;
	#$adr += 4;

}


