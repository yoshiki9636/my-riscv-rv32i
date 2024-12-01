;*
;* My RISC-V RV32I CPU
;*   Test Code IF/ID Instructions : No.2
;*    RV32I code
;* @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
;* @copylight	2021 Yoshiki Kurokawa
;* @license		https://opensource.org/licenses/MIT     MIT license
;* @version		0.1
;*

nop
nop
; clear LED to black
addi x1, x0, 7 ; LED value
lui x2, 0xc0010 ; LED address
addi x2, x2, 0xe00 ;
sw x1, 0x0(x2) ; set LED
; test xori
:fail_test1
ori x3, x0, 0x255
xori x3, x3, 0x5a5
ori x4, x0, 0x7f0
bne x4, x3, fail_test1
; next value
addi x1, x0, 6 ; LED value
sw x1, 0x0(x2) ; set LED
; test ori
:fail_test2
ori x5, x0, 0x555
ori x5, x5, 0x0af
ori x4, x0, 0x5ff
bne x5, x4, fail_test2
; next value
addi x1, x0, 5 ; LED value
sw x1, 0x0(x2) ; set LED
; test andi
:fail_test3
lui x7, 0xdeadb ; test value
ori x7, x7, 0x4ef ;
andi x7, x7, 0xe50 ; test
lui x8, 0xdeadb ; check value
ori x8, x8, 0x440 ; check value
bne x7, x8, fail_test3
; next value
addi x1, x0, 4 ; LED value
sw x1, 0x0(x2) ; set LED
; test slli
:fail_test4
ori x9, x0, 0x025a ; 
slli x9, x9, 13 ; test 1
lui x10, 0x004b4 ; check value
bne x9, x10, fail_test4
; next value
addi x1, x0, 3 ; LED value
sw x1, 0x0(x2) ; set LED
; test srli
:fail_test5
lui x11, 0x84b40 ; check value
srli x11, x11, 17 ; test 1
lui x12, 0x00004 ; check value
ori x12, x12, 0x25a ; 
bne x11, x12, fail_test5
; next value
addi x1, x0, 2 ; LED value
sw x1, 0x0(x2) ; set LED
; test srai
:fail_test6
lui x11, 0x84b40 ; check value
srai x11, x11, 17 ; test 1
lui x12, 0xffffc ; check value
ori x12, x12, 0x25a ; 
bne x11, x12, fail_test6
; next value
addi x1, x0, 1 ; LED value
sw x1, 0x0(x2) ; set LED
:fail_test7
lui x11, 0x04b40 ; check value
srai x11, x11, 17 ; test 1
ori x12, x0, 0x25a ; 
bne x11, x12, fail_test6
; next value
addi x1, x0, 0 ; LED value
sw x1, 0x0(x2) ; set LED
; test finished
nop
nop
lui x2, 01000 ; loop max
;ori x2, x0, 10 ; loop max
and x3, x0, x3 ; LED value
and x4, x0, x4 ;
lui x4, 0xc0010 ; LED address
addi x4, x4, 0xe00 ;
:label_led
and x1, x0, x1 ; loop counter
:label_waitloop
addi x1, x1, 1
blt x1, x2, label_waitloop
addi x3, x3, 1
sw x3, 0x0(x4)
jalr x0, x0, label_led
nop
nop
nop
nop
