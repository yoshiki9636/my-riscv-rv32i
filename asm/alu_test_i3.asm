;*
;* My RISC-V RV32I CPU
;*   Test Code ALU Instructions : No.3
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
; test add
:fail_test1
and x3, x0, x3
ori x4, x0, 1
sub x3, x3, x4
ori x4, x0, 0x200
add x3, x3, x4
ori x4, x0, 0x1ff
bne x4, x3, fail_test1
; next value
addi x1, x0, 6 ; LED value
sw x1, 0x0(x2) ; set LED
; test sub
:fail_test2
ori x5, x0, 0x3ff
ori x6, x0, 0x400
sub x5, x5, x6
ori x6, x0, 0xfff
bne x5, x6, fail_test2
; next value
addi x1, x0, 5 ; LED value
sw x1, 0x0(x2) ; set LED
; test sll
:fail_test3
ori x7, x0, 0x5a5
ori x8, x0, 0x11
sll x7, x7, x8
lui x8, 0x0b4a0
bne x7, x8, fail_test3
; next value
addi x1, x0, 4 ; LED value
sw x1, 0x0(x2) ; set LED
; test slt
:fail_test4
ori x9, x0, 1
and x10, x0, x10
sub x10, x10, x9
slt x9, x9, x10
and x10, x0, x10
bne x9, x10, fail_test4
; next value
addi x1, x0, 3 ; LED value
sw x1, 0x0(x2) ; set LED
; test slt (2)
:fail_test5
ori x9, x0, 1
and x10, x0, x10
sub x9, x10, x9
slt x9, x9, x10
ori x10, x0, 1
bne x9, x10, fail_test5
; next value
addi x1, x0, 2 ; LED value
sw x1, 0x0(x2) ; set LED
; test sltu
:fail_test6
ori x9, x0, 1
and x10, x0, x10
sub x10, x10, x9
sltu x9, x9, x10
ori x10, x0, 1
bne x9, x10, fail_test6
; next value
addi x1, x0, 1 ; LED value
sw x1, 0x0(x2) ; set LED
; test sltu (2)
:fail_test7
ori x9, x0, 1
and x10, x0, x10
sub x9, x10, x9
sltu x9, x9, x10
and x10, x0, x10
bne x9, x10, fail_test5
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
