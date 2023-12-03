# my-riscv-rv32i  
  
My RISC-V RV32I CPU  
RISC-V RV32I instruction set CPU for study  
(Currently Japanese document only)
  
Seed FPGA board Tang Primer動作を目指したRISC-V RV32I命令セットのverilog RTL論理および動作環境です。  
一応Tang Primerを謳っておりますが、clock PLLのみIP使用であり、特殊な記述もないため、  
他のFPGAへの移植も容易と思います。  

※2021/9/5
Xilinx Artix-7のDigilent Arty A7での設定と、MMCMの記述を追加しました。MMCMは~90MHz~85MHzで動作確認しました。
現在fpga_top.vはArty A7設定になっております。Tang Primerでの使用時はifdef設定の変更をお願いします。
  
1.1 Version 0.3の制約  
- 0.2と比較してinterruptピンを使った外部割込み（単体）、mretの実装を追加。
　privilegeはM-modeのみ。
- ALU周り、Load/Store、Jump、csr系とecallを作成。  
- fence系、ecall以外のecall系、exception未実装。  
- メモリはinstructionとdataでセパレート。各々1KWordsの大きさ。  
- I/OはRGB LEDの3ピンのみ。  
  
2. 簡単な使い方  
  
まずはgit cloneしてください。  
  
2.1 RTL simulation  
Intel FPGA用に配布されている、Modelsim 10.5b で動作確認しております。  
基本的なverilog記述しか使用していないので、大抵のシミュレータで動作可能と思います。  
  
(1) ssim/ディレクトリを作成し、cpu/ fpga/ io/ mon/ sim/の内容をコピーします。  
  
(2) asm/ディレクトリで riscv-asm1.plを使い、テスト命令列test.txtを作成。ssim/にコピーします。  
　　例：./risc-vasm1.pl lchika.asm > test.txt  
  
(3) ssim/内でverilogシミュレータを動作させます。　  
  
2.3 Tang Primer Synthesis & run  
  
Tang Primer専用のIDEを使用して合成、FPGAへの書き込みを行います。詳しくは、SiPEEDのページを参照ください。  
https://tang.sipeed.com/en/  
  
(1) ssyn/ディレクトリを作成し、cpu/ fpga/ io/ mon/ syn/の内容をコピーします。fpga_top.v内のifdefはTANG_PRIMERを有効にしてください。  
  
(2) IDEを立ち上げ、プロジェクトを作成、ssynをディレクトリに指定して、すべてのverilogファイルを指定します。  
  
(3) PLLの追加が必要なので、Tools->IP Generatorを選択し、Create New IPから、PLLを選択します。名称はpll、入力24MHz、出力36MHzとして作成します。  
  
(3.1) ssyn/uart_if.vの周波数設定が36MHz設定にします。  
  
(4) 後は用法通りに合成、書き込みをします。  
  
(5) USB - UART変換器を使って、FPGAとシリアル通信します。変換器のRxをB15、TxをB16、GndをGのどれかに接続します。  
  
(6) Teratermを使ってシリアル通信をします。Teratermの新しい接続で、シリアルを選択し、COMを変換器のものにします。  
  
(7) 設定->シリアルポートで、スピード:9600　データ:8bit　パリティ:none　ストップビット:1bit フロー制御:none  
  
(8) 設定->端末で、　改行コード　受信:AUTO　送信:CR　これでキーボードをたたくとエコーバックが帰ってくれば、動いております。  
  
(9) プログラムを書き込みます。qを押して、状態をクリアしたのち、i 00000000と打ち込むと、改行されます。シミュレーションで作ったtest.txtの内容をコピペしてください。最後にqを押します。  
  
(10) 書き込んだプログラムをダンプするには、p 00000000 00000100と打ち込んでください。先ほどのプログラムがダンプされます。  
  
(11) 実行は、g 00000000で実行状態になります。lchika.asmであれば、RGB LEDが色を変化させます。そのほかのテストプログラムも項目を確認後、テストパスがわかるように同じようなLチカとなります。  
  
(12) 実行の停止もqで停止します。それ以外のコマンドは、以下の通りです。  
  
	command format
	g : goto PC address ( run program until quit ) : format:  g <start addess>
	q : quit from any command                      : format:  q
	w : write date to memory                       : format:  w <start adderss> <data> ....<data> q
	r : read data from memory                      : format:  r <start address> <end adderss>
	t : trashed memory data and 0 clear            : format:  t
	s : program step execution                     : format:  s
	p : read instruction memory                    : format:  p <start address> <end adderss>
	i : write instruction memory                   : format:  i <start adderss> <data> ....<data> q
	j : print current PC value                     : format:  j

2.4 Arty A7 Synthesis & Run  

Digilent Arty A7を使う場合の合成方法のメモです。Xilinx Vivadoを使用します。詳しくはArty A7の設計ドキュメントを探してください。

(1) ssyn/ディレクトリを作成し、cpu/ fpga/ io/ mon/ をコピーしてください。ssyn/riscv_io_pins.xdcをコピーします。fpga_top.vのifdefをARTY_A7を有効にしてください。
　　
(2) Vivadoを立ち上げ、projectを作成、ssynの中のRTLを指定し、constraintsとして、riscv_io_pins.xdcを指定します。　　

(3) MMCMの追加が必要なので、IPカタログから追加します。周波数は入力100MHz、出力90MHzで動作を確認しております。
　　
(3.1) ssyn/uart_if.vの周波数設定を90MHzにします。  
  
(4) Vivadoのお作法で合成以下を行い、Arty A7に書き込みます。
  
(5) Arty A7はUSB接続がUARTとして使用できるので、特にUART変換器は必要ありません。あとはTang Primerの方法(7)からと同一です。
  
-----  
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
