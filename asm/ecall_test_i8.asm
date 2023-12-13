;*
;* My RISC-V RV32I CPU
;*   Test Code CSR and ecall : No.8
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
sh x1, 0x0(x2) ; set LED
; test csrrwi
:fail_test1
csrrwi x3, 0x305, 0x15
csrrwi x4, 0x305, 0x0
csrrwi x5, 0x305, 0xa
csrrwi x6, 0x305, 0x0
csrrwi x7, 0x305, 0x1f
ori x8, x0, 0x15 ; expect
bne x4, x8, fail_test1
ori x8, x0, 0xa ; expect
bne x6, x8, fail_test1
ori x8, x0, 0x0 ; expect
bne x5, x8, fail_test1
bne x7, x8, fail_test1
; next value
addi x1, x0, 6 ; LED value
sb x1, 0x0(x2) ; set LED
; test csrrw
:fail_test2
ori x8, x0, 0x5a5
csrrw x3, 0x305, x8
ori x8, x0, 0xa5a
csrrw x4, 0x305, x8
ori x8, x0, 0x0
csrrw x5, 0x305, x8
ori x8, x0, 0x5a5
bne x4, x8, fail_test2
ori x8, x0, 0xa5a
bne x5, x8, fail_test2
; next value
addi x1, x0, 5 ; LED value
sb x1, 0x0(x2) ; set LED
; test csrrsi
:fail_test3
ori x8, x0, 0x0
csrrw x3, 0x305, x8
csrrsi x4, 0x305, 0x15
csrrsi x5, 0x305, 0xa
csrrsi x6, 0x305, 0x0
ori x8, x0, 0x15
bne x5, x8, fail_test3
ori x8, x0, 0x1f
bne x6, x8, fail_test3
; next value
addi x1, x0, 4 ; LED value
sb x1, 0x0(x2) ; set LED
; test csrrs
:fail_test4
ori x8, x0, 0x0
csrrw x3, 0x341, x8
ori x8, x0, 0x5a5
csrrs x4, 0x341, x8
ori x8, x0, 0xa5a
csrrs x5, 0x341, x8
ori x8, x0, 0x0
csrrs x6, 0x341, x8
ori x8, x8, 0x5a5
bne x5, x8, fail_test4
ori x8, x0, 0xfff
bne x6, x8, fail_test4
; next value
addi x1, x0, 3 ; LED value
sb x1, 0x0(x2) ; set LED
; test csrrci
:fail_test5
ori x8, x0, 0xfff
csrrw x3, 0x342, x8
csrrci x4, 0x342, 0x15
csrrci x5, 0x342, 0x0a
csrrci x6, 0x342, 0x00
ori x8, x0, 0xfea
bne x5, x8, fail_test5
ori x8, x0, 0xfe0
bne x6, x8, fail_test5
; next value
addi x1, x0, 2 ; LED value
sb x1, 0x0(x2) ; set LED
; test csrrc
:fail_test6
ori x8, x0, 0xfff
csrrw x3, 0x305, x8
ori x8, x0, 0x555
csrrc x4, 0x305, x8
ori x8, x0, 0xaaa
csrrc x5, 0x305, x8
ori x8, x0, 0
csrrc x6, 0x305, x8
ori x8, x0, 0xaaa
bne x5, x8, fail_test6
ori x8, x0, 0
bne x6, x8, fail_test6
; test 0x300
ori x8, x0, 0xfff
csrrw x3, 0x300, x8
csrrw x4, 0x300, x8
ori x8, x0, 0xfcf
bne x4, x8, fail_test6
; next value
addi x1, x0, 1 ; LED value
sb x1, 0x0(x2) ; set LED
; test ecall
:fail_test7
lui x3, 0x00000 ;
ori x3, x3, 0x180
csrrw x4, 0x305, x3
csrrw x5, 0x305, x3
bne x5, x3, fail_test7
ecall
jalr x0, x0, fail_test7
jalr x0, x0, fail_test7
jalr x0, x0, fail_test7
jalr x0, x0, fail_test7
; 0x0180
addi x1, x0, 0 ; LED value
sb x1, 0x0(x2) ; set LED
ori x6, x0, 0x16c
ori x7, x0, 11
nop
nop
csrrs x4, 0x341, x0
csrrs x5, 0x342, x0
bne x4, x6, fail_test7
bne x5, x7, fail_test7
nop
nop
lui x2, 01000 ; loop max
;ori x2, x0, 10 ; small loop for sim
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
sh x3, 0x0(x4)
jalr x0, x0, label_led
nop
nop
nop
nop
