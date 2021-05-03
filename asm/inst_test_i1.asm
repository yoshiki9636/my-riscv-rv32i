;*
;* My RISC-V RV32I CPU
;*   Test Code IF/ID Instructions : No.1
;*    Verilog code
;* @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
;* @copylight	2021 Yoshiki Kurokawa
;* @license		https://opensource.org/licenses/MIT     MIT license
;* @version		0.1
;*

nop
nop
; clear LED to black
addi x1, x0, 7 ; LED value
lui x2, 0xc0000 ; LED address
sb x1, 0x0(x2) ; set LED
; test lui
:fail_test1
lui x3, 0x00fef ; test value
srli x3, x3, 12
ori x4, x0, 0xfef
bne x4, x3, fail_test1
; next value
addi x1, x0, 6 ; LED value
sb x1, 0x0(x2) ; set LED
; test auipc
:fail_test2
auipc x5, 0x12345 ; test value
lui x6, 0x12345 ; check value
srli x6, x6, 36
bne x5, x6, fail_test2
; next value
addi x1, x0, 5 ; LED value
sb x1, 0x0(x2) ; set LED
; test addi
:fail_test3
lui x7, 0x0dead ; test value
ori x7, x7, 0x123 ;
addi x7, x7, 0x456 ; test
lui x8, 0x0dead ; check value
ori x8, x8, 0x579 ; check value
bne x7, x8, fail_test3
; next value
addi x1, x0, 4 ; LED value
sb x1, 0x0(x2) ; set LED
; test slti
:fail_test4
ori x9, x0, 1 ; 
sub x9, x0, x9 ; make -1
slti x10, x9, 0x235 ; test 1
ori x11, x0, 1 ; check 1
bne x10, x11, fail_test4
; next value
addi x1, x0, 3 ; LED value
sb x1, 0x0(x2) ; set LED
:fail_test5
ori x9, x0, 0x234 ; 
slti x10, x9, 0x234 ; test 0
and x11, x0, x0 ; check 2
bne x10, x11, fail_test5
; next value
addi x1, x0, 2 ; LED value
sb x1, 0x0(x2) ; set LED
; test sltiu
:fail_test6
ori x12, x0, 1 ; 
sub x12, x0, x12 ; make -1
slti x13, x12, 0x235 ; test 0
ori x14, x0, 0 ; check 1
bne x13, x14, fail_test6
; next value
addi x1, x0, 1 ; LED value
sb x1, 0x0(x2) ; set LED
:fail_test7
ori x12, x0, 0x233 ; 
slti x13, x12, 0x234 ; test 1
and x14, x0, x0 ; check 2
bne x13, x14, fail_test7
addi x1, x0, 0 ; LED value
sb x1, 0x0(x2) ; set LED
; test finished
nop
nop
lui x2, 01000 ; loop max
and x3, x0, x3 ; LED value
and x4, x0, x4 ;
lui x4, 0xc0000 ; LED address
:label_led
and x1, x0, x1 ; loop counter
:label_waitloop
addi x1, x1, 1
blt x1, x2, label_waitloop
addi x3, x3, 1
sb x3, 0x0(x4)
jalr x0, x0, label_led
nop
nop
nop
nop
