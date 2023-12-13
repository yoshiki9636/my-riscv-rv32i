;*
;* My RISC-V RV32I CPU
;*   Test Code Store Instructions : No.6
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
lui x2, 0xc000f ; LED address
ori x2, x2, 0xe00 ;
sb x1, 0x0(x2) ; set LED
; store pattern data for test
lui x3, 0xa5a5a ;
ori x3, x3, 0x5a5 ; test value (1)
sw x3, 0x0(x0)
sw x3, 0x4(x0)
sw x3, 0x8(x0)
sw x3, 0xc(x0)
; test sb offset 0
:fail_test1
and x4, x4, x0
lui x5, 0xfedcb
ori x5, x5, 0x298
lui x7, 0x00001
srli x7, x7, 1
or x5, x5, x7
sb x5, 0x0(x4)
lw x6, 0x0(x4)
lui x7, 0xa5a5a
ori x7, x7, 0x598
bne x6, x7, fail_test1
; next value
addi x1, x0, 6 ; LED value
sb x1, 0x0(x2) ; set LED
; test sb offset 1
:fail_test2
and x8, x8, x0
ori x4, x0, 0x1
lui x5, 0x98fed
ori x5, x5, 0x4ba
lui x7, 0x00001
srli x7, x7, 1
or x5, x5, x7
sb x5, 0x0(x4)
lw x6, 0x0(x8)
lui x7, 0xa5a5b
ori x7, x7, 0x298
lui x8, 0x00001
srli x8, x8, 1
or x7, x7, x8
bne x6, x7, fail_test2
; next value
addi x1, x0, 5 ; LED value
sb x1, 0x0(x2) ; set LED
; test sb offset 2
:fail_test3
and x8, x8, x0
ori x4, x0, 0x2
lui x5, 0xba98f
ori x5, x5, 0x6dc
lui x7, 0x00001
srli x7, x7, 1
or x5, x5, x7
sb x5, 0x0(x4)
lw x6, 0x0(x8)
lui x7, 0xa5dcb
ori x7, x7, 0x298
lui x8, 0x00001
srli x8, x8, 1
or x7, x7, x8
bne x6, x7, fail_test3
; next value
addi x1, x0, 4 ; LED value
sb x1, 0x0(x2) ; set LED
; test sb offset 3
:fail_test4
and x8, x8, x0
ori x4, x0, 0x3
lui x5, 0xdcba9
ori x5, x5, 0x0fe
lui x7, 0x00001
srli x7, x7, 1
or x5, x5, x7
sb x5, 0x0(x4)
lw x6, 0x0(x8)
lui x7, 0xfedcb
ori x7, x7, 0x298
lui x8, 0x00001
srli x8, x8, 1
or x7, x7, x8
bne x6, x7, fail_test4
; next value
addi x1, x0, 3 ; LED value
sb x1, 0x0(x2) ; set LED
; test sh offset 0
:fail_test5
ori x8, x0, 0x4
ori x4, x0, 0x4
lui x5, 0xfedcb
ori x5, x5, 0x298
lui x7, 0x00001
srli x7, x7, 1
or x5, x5, x7
sh x5, 0x0(x4)
lw x6, 0x0(x8)
lui x7, 0xa5a5b
ori x7, x7, 0x298
lui x8, 0x00001
srli x8, x8, 1
or x7, x7, x8
bne x6, x7, fail_test5
; next value
addi x1, x0, 2 ; LED value
sb x1, 0x0(x2) ; set LED
; test sh offset 1
:fail_test6
ori x8, x0, 0x4
ori x4, x0, 0x6
lui x5, 0xba98f
ori x5, x5, 0x6dc
lui x7, 0x00001
srli x7, x7, 1
or x5, x5, x7
sh x5, 0x0(x4)
lw x6, 0x0(x8)
lui x7, 0xfedcb
ori x7, x7, 0x298
lui x8, 0x00001
srli x8, x8, 1
or x7, x7, x8
bne x6, x7, fail_test6
; next value
addi x1, x0, 1 ; LED value
sb x1, 0x0(x2) ; set LED
; test sw 
:fail_test7
ori x8, x0, 0x8
ori x4, x0, 0x8
lui x5, 0x76543
ori x5, x5, 0x210
sw x5, 0x0(x4)
lw x6, 0x0(x8)
lui x7, 0x76543
ori x7, x7, 0x210
bne x6, x7, fail_test7
; next value
addi x1, x0, 0 ; LED value
sb x1, 0x0(x2) ; set LED
; test finished
nop
nop
lui x2, 01000 ; loop max
;ori x2, x0, 10
and x3, x0, x3 ; LED value
and x4, x0, x4 ;
lui x4, 0xc000f ; LED address
ori x4, x4, 0xe00 ;
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
