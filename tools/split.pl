#!/bin/perl

open (F0, ">test0.txt") or die "cannot open test0.txt";
open (F1, ">test1.txt") or die "cannot open test1.txt";
open (F2, ">test2.txt") or die "cannot open test2.txt";
open (F3, ">test3.txt") or die "cannot open test3.txt";

while (<>) {
	if (/^(..)(..)(..)(..)$/) {
		print F0 "$4\n";
		print F1 "$3\n";
		print F2 "$2\n";
		print F3 "$1\n";
	}
}

close (F0);
close (F1);
close (F2);
close (F3);
