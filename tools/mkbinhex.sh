#!/bin/bash

for file in $(ls ./${1}*); do
	echo $file
	riscv64-unknown-elf-objcopy -O binary $file ${file}.bin
	od -An -tx4 -w4 -v ${file}.bin > ${file}.hex
done
