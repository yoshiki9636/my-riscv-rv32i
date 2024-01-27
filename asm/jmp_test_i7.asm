;*
;* My RISC-V RV32I CPU
;*   Test Code Jump Instructions : No.7
;*    RV32I code
;* @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
;* @copylight	2021 Yoshiki Kurokawa
;* @license		https://opensource.org/licenses/MIT     MIT license
;* @version		0.1
;*

:zero
nop
nop
; clear LED to black
addi x1, x0, 7 ; LED value
lui x2, 0xc0010 ; LED address
addi x2, x2, 0xe00 ;
sw x1, 0x0(x2) ; set LED
; test jal
:fail_test1
jal x3, ok_test1
jal x4, fail_test1
jal x4, fail_test1
jal x4, fail_test1
:ok_test1
jal x3, ok2_test1
jal x4, fail_test1
:ok2_test1
; next value
addi x1, x0, 5 ; LED value
sw x1, 0x0(x2) ; set LED
ori x5, x0, 0x2c
bne x3, x5, fail_test1
; next value
addi x1, x0, 6 ; LED value
sw x1, 0x0(x2) ; set LED
; test jalr
:fail_test2
jalr x3, x0, ok_test2
jalr x3, x0, ok2_test2
jal x4, fail_test2
jal x4, fail_test2
:ok_test2
jalr x3, x3, zero
jal x4, fail_test2
:ok2_test2
ori x5, x0, 0x50
bne x3, x5, fail_test2
; next value
addi x1, x0, 5 ; LED value
sw x1, 0x0(x2) ; set LED
; test beq
:fail_test3
ori x6, x0, 5
ori x7, x0, 4
ori x8, x0, 5
ori x9, x0, 6
beq x6, x7, fail_test3
beq x6, x9, fail_test3
beq x6, x8, ok_test3
jal x4, fail_test3
:ok_test3
; next value
addi x1, x0, 4 ; LED value
sw x1, 0x0(x2) ; set LED
; test bne
:fail_test4
ori x6, x0, 5
ori x7, x0, 4
ori x8, x0, 5
ori x9, x0, 6
bne x6, x8, fail_test4
bne x6, x7, ok_test4
jal x4, fail_test4
:ok_test4
bne x6, x9, ok2_test4
jal x4, fail_test4
:ok2_test4
; next value
addi x1, x0, 3 ; LED value
sw x1, 0x0(x2) ; set LED
; test blt
:fail_test5
ori x6, x0, 5
lui x7, 0xfffff
ori x7, x7, 0xfff
ori x8, x0, 5
ori x9, x0, 6
blt x6, x7, fail_test5
blt x6, x8, fail_test5
blt x6, x9, ok_test5
jal x4, fail_test5
:ok_test5
; next value
addi x1, x0, 2 ; LED value
sw x1, 0x0(x2) ; set LED
; test bge
:fail_test6
ori x6, x0, 5
lui x7, 0xfffff
ori x7, x7, 0xfff
ori x8, x0, 5
ori x9, x0, 6
bge x6, x9, fail_test6
bge x6, x7, ok_test6
jal x4, fail_test6
:ok_test6
bge x6, x8, ok2_test6
jal x4, fail_test6
:ok2_test6
; next value
addi x1, x0, 1 ; LED value
sw x1, 0x0(x2) ; set LED
; test bltu 
:fail_test7
ori x6, x0, 5
lui x7, 0xfffff
ori x7, x7, 0xfff
ori x8, x0, 5
ori x9, x0, 6
ori x10, x0, 4
bltu x6, x10, fail_test7
bltu x6, x8, fail_test7
bltu x6, x9, ok_test7
jal x4, fail_test7
:ok_test7
bltu x6, x7, ok2_test7
jal x4, fail_test7
:ok2_test7
; next value
addi x1, x0, 0 ; LED value
sw x1, 0x0(x2) ; set LED
; test bgeu 
:fail_test8
ori x6, x0, 5
ori x7, x0, 4
ori x8, x0, 5
ori x9, x0, 6
lui x10, 0xfffff
ori x10, x10, 0xfff
bgeu x6, x9, fail_test8
bgeu x6, x10, fail_test8
bgeu x6, x7, ok_test8
jal x4, fail_test8
:ok_test8
bgeu x6, x8, ok2_test8
jal x4, fail_test8
:ok2_test8
; test finished
nop
nop
lui x2, 01000 ; loop max
;ori x2, x0, 10
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
