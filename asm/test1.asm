;*
;* My RISC-V RV32I CPU
;*   1st Test Code 
;*    RV32I code
;* @auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>
;* @copylight	2021 Yoshiki Kurokawa
;* @license		https://opensource.org/licenses/MIT     MIT license
;* @version		0.1
;*

nop
nop
and x1, x0, x1 ; x1 = 0
and x2, x0, x2 ; x2 = 0
and x3, x0, x3 ; x3 = 0
addi x3, x3, 5 
:label1
addi x1, x1, 1 
sw x1, 0x0(x2)
addi x2, x2, 1 
blt x2, x3, label1
:label2
jalr x4, x0, label2
nop
nop
nop
nop
