# my-riscv-rv32i  
  
My RISC-V RV32I CPU  
  
RISC-V RV32I instruction set CPU for study  
  
Design Memo ( Japanese )  
  
1.パイプライン設計  
  
パイプライン 5段　MIPSと同等  
  
	| IF | ID | EX | MA | WB |  
	      ITLB      DTLB  
  
TLBのCAMはFPGAで作成可能　らしい・・・  
初期作はTLB実装しない。imemとdmemハーバードアーキ  
  
IF imemリード発行、PCインクリメント  
  
ID imem出力をデコード　RFリード発行　直値なども生成  
  
EX RF出力とフォワード値をセレクト　演算実行  
  
MA　dmemライト/リードを発行　フォワーディング  
  
WB　パイプラインとdmemリードのセレクト　RFライト発行　フォワーディング  
  
  
2.命令のフォーマット分類  
  
(1) fmt1  
  
	31-27 | 26-25 | 24-20 | 19-15 | 14-12 | 11-7 | 6-2 | 1-0  
	imm[32:12]                            | rd   | op1 | 11  
  
lui   : op1 01101  
auipc : op1 00101  
  
  
	31-27 | 26-25 | 24-20 | 19-15 | 14-12 | 11-7 | 6-2 | 1-0  
	imm[20|10:1|11~19:12]                 | rd   | op1 | 11  
  
jal  : op1 11011  
  
  
(2) fmt2  
  
	31-27 | 26-25 | 24-20 | 19-15 | 14-12 | 11-7 | 6-2 | 1-0  
	imm[11:0]             | rs1   | op2   | rd   | op1 | 11  
  
	addi  : op1 00100  op2 000  
	slti  : op1 00100  op2 010   
	sltiu : op1 00100  op2 011   
	xori  : op1 00100  op2 100   
	ori   : op1 00100  op2 110   
	andi  : op1 00100  op2 111   
 	
	csrrw : op1 11100  op2 001   
	csrrs : op1 11100  op2 010   
	csrrc : op1 11100  op2 011   
	csrrwi: op1 11100  op2 101  rs1 uimm  
	csrrsi: op1 11100  op2 110  rs1 uimm  
	csrrci: op1 11100  op2 111   
  
	lb    : op1 00000  op2 000   
	lh    : op1 00000  op2 001   
	lw    : op1 00000  op2 010   
	lbu   : op1 00000  op2 100   
	lhu   : op1 00000  op2 101   
	
	jalr  : op1 11001  op2 000   
  
  
(3) fmt3  
  
	31-27 | 26-25 | 24-20 | 19-15 | 14-12 | 11-7 | 6-2 | 1-0  
	op3   | 0X    | shamt | rs1   | op2   | rd   | op1 | 11  
  
	slli : op1 00100  op2 001  op3 00000  
	srli : op1 00100  op2 101  op3 00000  
	srai : op1 00100  op2 101  op3 01000  
  
(4) fmt4  
  
	31-27 | 26-25 | 24-20 | 19-15 | 14-12 | 11-7 | 6-2 | 1-0  
	op3   | 00    | rs2   | rs1   | op2   | rd   | op1 | 11  
  
  
	add  : op1 01100  op2 000  op3 00000  
	sub  : op1 01100  op2 000  op3 01000  
	sll  : op1 01100  op2 001  op3 00000  
	slt  : op1 01100  op2 010  op3 00000  
	sltu : op1 01100  op2 011  op3 00000  
	xor  : op1 01100  op2 100  op3 00000  
	srl  : op1 01100  op2 101  op3 00000  
	sra  : op1 01100  op2 101  op3 01000  
	or   : op1 01100  op2 110  op3 00000  
	and  : op1 01100  op2 111  op3 00000  
  
(5) fmt5  
  
	31-28 | 27-24 | 23-20 | 19-15 | 14-12 | 11-7 | 6-2 | 1-0  
	0000  | pred  | succ  | 00000 | op2   | 00000| op1 | 11  
  
	fence   : op1 00011  op2 000   
	fence.i : op1 00011  op2 001  pred 0000  succ 0000  
  
(6) fmt6  
  
	31-27 | 26-25 | 24-20 | 19-15 | 14-12 | 11-7 | 6-2 | 1-0  
	op3   | 00    | op4   | 00000 | op2   | 00000| op1 | 11  
  
	ecall  : op1 11100  op2 000  op3 00000  op4 00000  
	ebreak : op1 11100  op2 000  op3 00000  op4 00001  
	uret   : op1 11100  op2 000  op3 00000  op4 00010  
	sret   : op1 11100  po2 000  op3 00010  op4 00010  
	mret   : op1 11100  po2 000  op3 00110  op4 00010  
	wfi    : op1 11100  po2 000  op3 00010  op4 00101  
  
(7) fmt7  
  
	31-27 | 26-25 | 24-20 | 19-15 | 14-12 | 11-7 | 6-2 | 1-0  
	op3   | op5   | rs2   | rs1   | op2   | rd   | op1 | 11  
  
	same as (4) fmt4  
	sfence.vma : op1 11100  op2 000  op3 00010  op5 01  
  
(8) fmt8  
  
	31-27 | 26-25 | 24-20 | 19-15 | 14-12 | 11-7  | 6-2 | 1-0  
	of[11:5]      | rs2   | rs1   | op2   |of[4:0]| op1 | 11  
  
	sb  : op1 01000  op2 000   
	sh  : op1 01000  op2 001   
	sw  : op1 01000  op2 010   
  
(9) fmt9  
  
	31-27 | 26-25 | 24-20 | 19-15 | 14-12 | 11-7     | 6-2 | 1-0  
	of[12|10:5]   | rs2   | rs1   | op2   |of[4:1|11]| op1 | 11  
  
	beq  : op1 11000  op2 000   
	bne  : op1 11000  op2 001   
	blt  : op1 11000  op2 100   
	bge  : op1 11000  op2 101   
	bltu : op1 11000  op2 110   
	bgeu : op1 11000  op2 111   
  
  
3.Pipeline stage Design  
  
3.1 EX Stage  
ALU  
add,sub  
  
	rs2_i = rs2 ^ { 32{ subflg }};  
	intm[32:0] = { rs1, 1'b1 } + { rs2_i, subflg };  
	result = intm[32:1];  
  
and  
or  
xor  
l shift  
r shift  
  
Branch  
	eq : rs1 == rs2  
	ne : rs1 != rs2 : ~eq  
	lt : rs1 <  rs2 : rs1 - rs2 < 0  
	ge : rs1 >= rs2 : ~lt  
	ltu,geu same but other logic  
  
Address calculation for load/store  
  
	add rs1 or rs2 and offset  
	add at ALU  
  
Address calculation for jump address,branch  
  
  
  
3.2 MA Stage  
  
Data memory  
address 加算は終了  
load :  adr[1:0] とop1　次へ  
store : adr[1:0] とop1でライトイネーブル作成　データ位置をシフト   
書き込み　or 読み出し　発行  
  
  
3.3 WB Stage  
  
load : adr[1:0]とop1でデータ位置シフト　wbへ  
それ以外、wbへ  
  
  
4. パイプラインフォワーディング  
  
	| IF | ID | EX | MA | WB |  
  
Timing chart  
  
	IF: | r1 | r2 | r3 | r4 | r5 |  
	ID:      | r1 | r2 | r3 | r4 | r5 |  
	EX:           | r1 | r2 | r3 | r4 | r5 |  
	MA:                | r1 | r2 | r3 | r4 | r5 |  
	WB:                     | r1 | r2 | r3 | r4 | r5 |  
  
not load  
  
(1) EX -> EX  

	IF: | r1 | r2 | r2 | r4 | r5 |  
	ID:      | r1 | r2 | r2 | r4 | r5 |  
	EX:           | r1 | r2*|*r2 | r4 | r5 |  
	MA:                | r1 | r2 | r2 | r4 | r5 |  
	WB:                     | r1 | r2 | r2 | r4 | r5 |  
  
(2) MA -> EX  

	IF: | r1 | r2 | r3 | r2 | r5 |  
	ID:      | r1 | r2 | r3 | r2 | r5 |  
	EX:           | r1 | r2 | r3 |*r2 | r5 |  
	MA:                | r1 | r2*| r3 | r2 | r5 |  
	WB:                     | r1 | r2 | r3 | r2 | r5 |  
  
(3) WB -> EX  

	IF: | r1 | r2 | r3 | r4 | r2 |  
	ID:      | r1 | r2 | r3 | r4 | r2 |  
	EX:           | r1 | r2 | r3 | r4 |*r2 |  
	MA:                | r1 | r2 | r3 | r4 | r2 |  
	WB:                     | r1 | r2*| r3 | r4 | r2 |  
  
load only  
(4) WB -> MA  
  
	IF: | r1 | r2 | r2 | r4 | r5 |  
	ID:      | r1 | r2 | r2 | r4 | r5 |  
	EX:           | r1 | r2 | r2 | r4 | r5 |  
	MA:                | r1 | r2*|*r2 | r4 | r5 |  
	WB:                     | r1 | r2 | r2 | r4 | r5 |  
  
  
(5)JMP/Branch のパイプラインパージ  
  
	IF: | r1 | J2 | r3 | r4 |*N5 |  
	ID:      | r1 | J2 | r3 | x4 | N5 |  
	EX:           | r1 | J2*| x3 | x4 | N5 |  
	MA:                | r1 | J2 | x3 | x4 | N5 |  
	WB:                     | r1 | J2 | x3 | x4 | N5 |  
  
  
  
  
  
  
 	@auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>  
 	@copylight	2021 Yoshiki Kurokawa  
 	@license	https://opensource.org/licenses/MIT     MIT license  
  
 	@version	0.1 First Commit and LED Chika Chika works on FPGA  
