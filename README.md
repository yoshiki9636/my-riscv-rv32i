# my-riscv-rv32i  
  
My RISC-V RV32I CPU  
RISC-V RV32I instruction set CPU for study  

### English
(Japanese follows English)

This RTL logics and operating environment of RISC-V RV32I instruction set is for aiming at woking on Seed FPGA board Tang Primer.
Although it is for a Tang Primer, only clock PLL is used for IP and there is no special description, I think it will be easy to port to other FPGAs.

※2021/9/5
Added description of Xilinx Artix-7 configuration with Digilent Arty A7 and MMCM. MMCM was confirmed to work at ~~90MHz~~85MHz.
Currently fpga_top.v is set to Arty A7. please change the ifdef setting when using Tang Primer.

1.1 Limitations of Version 0.31
- Added implementation of external interrupts (standalone) and mret using the interrupt pin compared to 0.2.
- ver 0.3 : added illegal operations exception.
- Privilege is M-mode only.
- Create around ALU, Load/Store, Jump, csr system and ecall.
- FENCE system, ECALL system other than ECALL, EXCEPTION are not implemented.
- Memory is separated by INSTRUCTION and DATA. Each is 1K Words in size.
- I/O has 4 sets of 3-pin RGB LED.
- Uart output using I/O supported.

2. simple usage
  
First, please do a git clone.
  
2.1 RTL simulation
We have confirmed the operation with Modelsim 10.5b, which is distributed for Intel FPGAs.
Since only basic verilog descriptions are used, it would work with most simulators.
  
(1) Create the ssim/ directory and copy the contents of cpu/ fpga/ io/ mon/ sim/.
  
(2) Use riscv-asm1.pl in the asm/ directory and create a test instruction sequence test.txt. copy it to ssim/.
　　Example:. /risc-vasm1.pl lchika.asm > test.txt
  
(3) Run the verilog simulator in ssim/.
  
2.3 Tang Primer Synthesis & run
  
Synthesis and writing to FPGA are performed using the IDE dedicated to Tang Primer. For details, please refer to the SiPEED page.
https://tang.sipeed.com/en/
  
(1) Create ssyn/ directory and copy the contents of cpu/ fpga/ io/ mon/ syn/. Ifdef in fpga_top.v should enable TANG_PRIMER.
  
(2) Launch the IDE, create a project, designate ssyn as a directory, and specify all verilog files.
  
(3) We need to add a PLL, so select Tools->IP Generator, and from Create New IP, select PLL. The name is created as pll, input 24MHz, output 36MHz.
  
(3.1) Set the frequency setting in ssyn/uart_if.v to the 36 MHz setting.
  
(4) After that, composite and write as per usage.
  
(5) Use a USB - UART converter for serial communication with the FPGA. Connect Rx to B15, Tx to B16, or Gnd to G of the converter.
  
(6) Serial communication using Teraterm: In Teraterm's New Connection, select Serial and set COM to that of the transducer.
  
(7) Setup->Serial port, speed: 9600, data: 8bit, parity: none, stop bit: 1bit, flow control: none
  
(8) In Configuration->Terminal, set the line feed code to Receive: AUTO Transmit: CR. If you get an echo back when you tap the keyboard with this code, it is working.
  
(9) Write the program. press Ctrl-c to clear the status, then type i 00000000 to start a new line. Copy and paste the contents of test.txt created in the simulation. Finally, press Ctrl-c.
  
(10) To dump the written program, type p 00000000 00000100. The program you just wrote will be dumped.
  
(11) Execution will be in execution state at g 00000000. lchika.asm will cause RGB LEDs to change color. Other test programs will be the same lchika so that the test path can be understood after checking the items.
  
(12) Stopping execution is also stopped with Ctrl-c. Other commands are as follows.
  
	command format
	g : goto PC address ( run program until quit ) : format: g <start addess>
	Ctrl-c : quit from any command : format: Ctrl-c
	w : write date to memory : format: w <start adderss> <data> ....<data> Ctrl-c
	r : read data from memory : format: r <start address> <end adderss>
	t : trashed memory data and 0 clear : format: t
	s : program step execution : format: s
	p : read instruction memory : format: p <start address> <end adderss>
	i : write instruction memory : format: i <start adderss> <data> ....<data> Ctrl-c
	j : print current PC value : format: j

2.4 Arty A7 Synthesis & Run

Here is a note on how to synthesize when using the Digilent Arty A7, using Xilinx Vivado. For more information, look for the Arty A7 design documentation.

(1) Create ssyn/ directory and copy cpu/ fpga/ io/ mon/ Copy ssyn/riscv_io_pins.xdc Copy ifdef in fpga_top.v with ARTY_A7 enabled.

(2) Start Vivado, create a project, specify RTL in ssyn, and specify riscv_io_pins.xdc as constraints.

(3) MMCM needs to be added from the IP catalog. We have confirmed operation with a frequency of 100 MHz input and 90 MHz output.

(3.1) Set the frequency setting in ssyn/uart_if.v to 90 MHz.
  
(4) Perform the following synthesis in the manner of Vivado and write to Arty A7.
  
(5) Since the Arty A7 can use the USB connection as a UART, no special UART converter is needed. The rest is identical to the Tang Primer method (7).


2.5 How to run C bare-metal programs

(1) https://github.com/riscv-collab/riscv-gnu-toolchain Create a tool chain. You may get stuck on the way, but it may be the version of git, so please be patient and deal with the errors. Note that this CPU only supports RV32i and the most basic instruction set, so do not make a mistake when you configure it.

./configure --prefix=/opt/riscv32i --with-arch=rv32i --with-abi=ilp32

make should select newlib.

make

(2) C samples are available in ctest/. It has been tested in the author's environment. Shell for compilation (Makefile was troublesome...) The name of the tool chain is written in the script. The tool name is written in the script, so please change it to the name of the tool in the above tool chain. After that, all you have to do is to run the shell.

./cmpl.sh XX.c

Various files such as binaries can be created, but all that is needed is XX.hex. Then, read XX.hex using the i command as in step 2. At this time, some programs (most of them) require an image on the D memory side as well, so use the w000000000 command to load the image on the D memory side as well. Execution is done g00000000. 

----------

Design Memo ( English )
  
1. Pipeline Design
  
Pipeline Equivalent to 5-stage MIPS
  
| IF | ID | EX | MA | WB |
	      ITLB DTLB
  
TLB's CAM can be created in FPGA...
Initial work does not implement TLB. imem and dmem Harvard Arch.
  
IF imem lead issued, PC increment
  
Decode ID imem output, issue RF reads, generate direct values, etc.
  
EX Select RF output and forward value Execute operation
  
MA dmem write/read issued Forwarding
  
WB Pipeline and dmem read select RF write issue forwarding
  
  
2. Instruction format classification
  
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
address adding is finished
load :  adr[1:0] & op1　: reading and going next stage
store : adr[1:0] & op1 : making write enable and shifting data alinment  
issued reading / writing memory

  
3.3 WB Stage  
  
load : adr[1:0] & op1 : shifting data alinment and going to write back  
others : going to write back
  
  
4. Pipeline forwarding
  
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
	EX:           | r1 | r2 | r2 |*r4 | r5 |  
	MA:                | r1 | r2*| r2 | r4 | r5 |  
	WB:                     | r1 | r2 | r2 | r4 | r5 |  
  
  
(5)JMP/Branch : pipeline purge 
  
	IF: | r1 | J2 | r3 | r4 |*N5 |  
	ID:      | r1 | J2 | r3 | x4 | N5 |  
	EX:           | r1 | J2*| x3 | x4 | N5 |  
	MA:                | r1 | J2 | x3 | x4 | N5 |  
	WB:                     | r1 | J2 | x3 | x4 | N5 |  
  
 
----------

### Japanese
  
Seed FPGA board Tang Primer動作を目指したRISC-V RV32I命令セットのverilog RTL論理および動作環境です。  
一応Tang Primerを謳っておりますが、clock PLLのみIP使用であり、特殊な記述もないため、  
他のFPGAへの移植も容易と思います。  

※2021/9/5
Xilinx Artix-7のDigilent Arty A7での設定と、MMCMの記述を追加しました。MMCMは~90MHz~85MHzで動作確認しました。
現在fpga_top.vはArty A7設定になっております。Tang Primerでの使用時はifdef設定の変更をお願いします。
  
1.1 Version 0.31の制約  
- 0.2と比較してinterruptピンを使った外部割込み（単体）、mretの実装を追加。
- 0.3から illegal operations exceptionを追加。
- privilegeはM-modeのみ。
- ALU周り、Load/Store、Jump、csr系とecallを作成。  
- fence系、ecall以外のecall系、exception未実装。  
- メモリはinstructionとdataでセパレート。各々1KWordsの大きさ。  
- I/Oは4セットのRGB LEDの12ピン。
- Uartでの表字をI/Oで実現。
  
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
  
(9) プログラムを書き込みます。Ctrl-cを押して、状態をクリアしたのち、i 00000000と打ち込むと、改行されます。シミュレーションで作ったtest.txtの内容をコピペしてください。最後にCtrl-cを押します。  
  
(10) 書き込んだプログラムをダンプするには、p 00000000 00000100と打ち込んでください。先ほどのプログラムがダンプされます。  
  
(11) 実行は、g 00000000で実行状態になります。lchika.asmであれば、RGB LEDが色を変化させます。そのほかのテストプログラムも項目を確認後、テストパスがわかるように同じようなLチカとなります。  
  
(12) 実行の停止もCtrl-cで停止します。それ以外のコマンドは、以下の通りです。  
  
	command format
	g : goto PC address ( run program until quit ) : format:  g <start addess>
	Ctrl-c : quit from any command                      : format:  Ctrl-c
	w : write date to memory                       : format:  w <start adderss> <data> ....<data> Ctrl-c
	r : read data from memory                      : format:  r <start address> <end adderss>
	t : trashed memory data and 0 clear            : format:  t
	s : program step execution                     : format:  s
	p : read instruction memory                    : format:  p <start address> <end adderss>
	i : write instruction memory                   : format:  i <start adderss> <data> ....<data> Ctrl-c
	j : print current PC value                     : format:  j

2.4 Arty A7 Synthesis & Run  

Digilent Arty A7を使う場合の合成方法のメモです。Xilinx Vivadoを使用します。詳しくはArty A7の設計ドキュメントを探してください。

(1) ssyn/ディレクトリを作成し、cpu/ fpga/ io/ mon/ をコピーしてください。ssyn/riscv_io_pins.xdcをコピーします。fpga_top.vのifdefをARTY_A7を有効にしてください。
　　
(2) Vivadoを立ち上げ、projectを作成、ssynの中のRTLを指定し、constraintsとして、riscv_io_pins.xdcを指定します。　　

(3) MMCMの追加が必要なので、IPカタログから追加します。周波数は入力100MHz、出力90MHzで動作を確認しております。
　　
(3.1) ssyn/uart_if.vの周波数設定を90MHzにします。  
  
(4) Vivadoのお作法で合成以下を行い、Arty A7に書き込みます。
  
(5) Arty A7はUSB接続がUARTとして使用できるので、特にUART変換器は必要ありません。あとはTang Primerの方法(7)からと同一です。

2.5 ベアメタルCプログラム動作方法

(1) riscv toolchainの整備

https://github.com/riscv-collab/riscv-gnu-toolchain 
を使ってツールチェーンを作成します。途中引っかかることがありますが、gitのバージョンだったりしますので、根気よくエラーに対応してください。 なお、本CPUはRV32iと、一番基本的な命令セットしかサポートしていないので、configureするときに指定を間違えないでください。

./configure --prefix=/opt/riscv32i --with-arch=rv32i --with-abi=ilp32

makeはnewlibを作成します。

make

ツールのbinへのパスを通しておいてください。

PATH=/opt/riscv32i/bin:$PATH

(2) Cのサンプルがctest/内にあります。作者の環境で動作確認しております。コンパイル用のシェル(Makefileが面倒だったもので。。。)があります。スクリプト内部にツール名が記載されていますので、上記ツールチェーンのツール名に変更してください。後はシェルを実行するだけです。

./cmpl.sh XX.c

バイナリ等いろいろファイルができますが、必要なのはXX.hexです。あとは2.の手順と同じようにiコマンドでXX.hexを読み込んでください。この時、プログラムによっては（ほとんどはそうですが）Dメモリ側にもイメージが必要なので、w000000000 コマンドでDメモリ側にもイメージを読み込んでください。実行はg00000000を行います。 

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
  
  
  
  EOF
  
  
 	@auther		Yoshiki Kurokawa <yoshiki.k963@gmail.com>  
 	@copylight	2021 Yoshiki Kurokawa  
 	@license	https://opensource.org/licenses/MIT     MIT license  
  
 	@version	0.1 First Commit and LED Chika Chika works on FPGA  
