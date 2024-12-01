;*
;* My RISC-V RV32I CPU
;*   Test Code IF/ID Instructions : No.1
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
; setup dma registers
; DMA IO start adr
lui x3, 0xc000f ; DMA base address
ori x3, x3, 0xfc4 ;
and x4, x0, x0 ; clear : start 0
sw x4, 0x0(x3) ; set IO start adr offset 0x4
; DMA mem start adr
xor x4, x4, x4 ; clear : start 0
ori x4, x4, 0x100 ; memory start 100
lui x3, 0xc000f ; DMA base address
ori x3, x3, 0xfc8 ;
sw x4, 0x0(x3) ; set IO start adr offset 0x4
; DMA data counter
xor x4, x4, x4 ; clear : start 0
ori x4, x4, 0x20 ; DMA data counter
lui x3, 0xc000f ; DMA base address
ori x3, x3, 0xfcc ;
sw x4, 0x0(x3) ; set IO start adr offset 0x4
; DMA write start
xor x4, x4, x4 ; clear : start 0
ori x4, x4, 0x2 ; DMA data counter
lui x3, 0xc000f ; DMA base address
ori x3, x3, 0xfc0 ;
sw x4, 0x0(x3) ; set IO start adr offset 0x4
; wait finish
:label_read_loop
lw x5, 0x0(x3) ; set IO start adr offset 0x4
beq x5, x4, label_read_loop
; DMA mem start adr
xor x4, x4, x4 ; clear : start 0
ori x4, x4, 0x300 ; memory start 100
lui x3, 0xc000f ; DMA base address
ori x3, x3, 0xfc8 ;
sw x4, 0x0(x3) ; set IO start adr offset 0x4
; DMA read start
xor x4, x4, x4 ; clear : start 0
ori x4, x4, 0x1 ; DMA data counter
lui x3, 0xc000f ; DMA base address
ori x3, x3, 0xfc0 ;
sw x4, 0x0(x3) ; set IO start adr offset 0x4
; wait finish
:label_write_loop
lw x5, 0x0(x3) ; set IO start adr offset 0x4
beq x5, x4, label_write_loop
; test finished
nop
nop
nop
nop
;lui x2, 01000 ; loop max
ori x2, x0, 10 ; small loop for sim
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
