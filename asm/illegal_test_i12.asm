;*
;* My RISC-V RV32I CPU
;*   Test Code : LED Chika Chika
;*    RV32I code
;* @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
;* @copylight	2021 Yoshiki Kurokawa
;* @license		https://opensource.org/licenses/MIT     MIT license
;* @version		0.1
;*
nop
nop
addi x7, x0, 0x64 ; trap vector 
csrrw x7, 0x305, x7 ; wirte to mtvec
ori x7, x0, 0x800 ; set meip bit on mie 
csrrw x7, 0x304, x7 ; wirte to mtvec
lui x2, 01000 ; loop max
;addi x2, x0, 10 ; loop max
and x3, x0, x3 ; LED value
and x4, x0, x4 ; 
lui x4, 0xc0010 ; LED address
addi x4, x4, 0xe00 ;
and x3, x0, x3 ; legal ops
and x3, x0, x3 ; legal ops
and x3, x0, x3 ; legal ops
and x3, x0, x3 ; legal ops
and x3, x0, x3 ; legal ops
and x3, x0, x3 ; legal ops
and x3, x0, x3 ; legal ops
and x3, x0, x3 ; legal ops
;and x3, x0, x3 ; legal ops
addi x5, x0, 1 ; LED mask value
jalr x0, x0, label_led
illegal_ops
nop
nop
nop
nop
addi x5, x0, 7 ; LED mask value
:label_led
and x1, x0, x1 ; loop counter
:label_waitloop
addi x1, x1, 1 
blt x1, x2, label_waitloop
addi x3, x3, 1 
and x6, x3, x5 ; masking
sw x6, 0x0(x4)
jalr x0, x0, label_led
nop
nop
nop
nop
