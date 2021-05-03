;*
;* My RISC-V RV32I CPU
;*   Test Code ALU Instructions : No.4
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
lui x2, 0xc0000 ; LED address
sb x1, 0x0(x2) ; set LED
; test xor
:fail_test1
lui x3, 0xaa55c
ori x3, x3, 0xc33
lui x4, 0xa5a5c
ori x4, x4, 0x3c3
xor x3, x3, x4
lui x4, 0x0ff00
ori x4, x4, 0xff0
bne x4, x3, fail_test1
; next value
addi x1, x0, 6 ; LED value
sb x1, 0x0(x2) ; set LED
; test srl
:fail_test2
lui x5, 0xaa55c
ori x5, x5, 0xc33
ori x6, x0, 0xfe3
srl x5, x5, x6
lui x6, 0x154ab
ori x6, x6, 0x986
bne x5, x6, fail_test2
; next srl (2)
addi x1, x0, 5 ; LED value
sb x1, 0x0(x2) ; set LED
:fail_test3
lui x5, 0xaa55c
ori x5, x5, 0xc33
ori x6, x0, 0xfff
srl x5, x5, x6
ori x6, x0, 1
bne x5, x6, fail_test3
; next value
addi x1, x0, 4 ; LED value
sb x1, 0x0(x2) ; set LED
; test sra
:fail_test4
lui x5, 0xaa55c
ori x5, x5, 0xc33
ori x6, x0, 0xfe1
sra x5, x5, x6
lui x6, 0x552ae
ori x6, x6, 0x619
bne x5, x6, fail_test4
; next value
addi x1, x0, 3 ; LED value
sb x1, 0x0(x2) ; set LED
; test sra (2)
:fail_test5
lui x5, 0xaa55c
ori x5, x5, 0xc33
ori x6, x0, 0xfff
sra x5, x5, x6
lui x6, 0x54ab9
ori x6, x6, 0x866
bne x5, x6, fail_test5
; next value
addi x1, x0, 2 ; LED value
sb x1, 0x0(x2) ; set LED
; test 
:fail_test6
lui x5, 0x76543
ori x5, x5, 0x210
lui x6, 0x89abc
ori x6, x6, 0xdef
or x5, x5, x6
lui x6, 0xfffff
ori x6, x6, 0xfff
bne x5, x6, fail_test6
; next value
addi x1, x0, 1 ; LED value
sb x1, 0x0(x2) ; set LED
; test and
:fail_test7
lui x5, 0x76543
ori x5, x5, 0x210
lui x6, 0xfffff
ori x6, x6, 0xfff
and x5, x5, x6
lui x6, 0x76543
ori x6, x6, 0x210
bne x5, x6, fail_test7
; next value
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
