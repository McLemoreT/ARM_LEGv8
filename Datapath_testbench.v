module Datapath_testbench (); 
			
/*	reg [63:0] A, B; //2 main inputs for ALU
	wire [63:0]F; //answer output of ALU
	wire [3:0]status; //status signalfrom ALU
	reg [4:0]FS;	//Ainvert (FS[0]), Binvert (FS[1]), and function selector for ALU (FS[4:2])
		//FS[4:2] funcitons are: 000 AND, 001 OR, 010 ADD, 011 xor, 100 shift left, 101 shift right	
		//note that when FS[4:0] = 11000 and beyond, output should be all zeroes, because it's undefined
	reg CO; //carry in?*/

wire [63:0] R5, R2, R0, R30, R15, R12, R1, /*M5,*/ R28, /*M200,*/ R22;
wire [63:0] data;
reg [63:0] constant;
reg [24:0] ControlWord;
reg clock, reset;
wire [3:0] status;
/*reg [63:0] D, DA;
reg [4:0] SA;
reg W;*/


	initial begin
		constant <= 64'd0;
		ControlWord <= 25'b0;
		reset <= 1;
		clock <= 0;
		#200 $stop; //then stop
	end
//Control word is defined as: {SA, SB, DA, RegWrite, MemWrite, FS, Bsel, EN_Mem, EN_ALU} = ControlWord;
	always begin
		//#10 data <= 64'd256;
		//ControlWord <= 25'b0000100010000001000000000;
		#5 reset <= 0;
		#15 constant <= 64'd4;
		ControlWord <= 25'b1111100000001011001000101;//loading 4 into R5
		
		#10 constant <= 64'd6;
		ControlWord <= 25'b1111100000000101001000101; //loading 6 into r2
		#10 constant <= 64'd35;
		ControlWord <= 25'b1111100000000001001000101; // loading 35 into R0
		
		#10 ControlWord <= 25'b0001000000001011001000001; //adding R2+R0 and putting in R5
		
		#10 constant <= 64'd34;
		ControlWord <= 25'b1111100000011111001000101; // loading 34 into R15
		#10 constant <= 64'd30;
		ControlWord <= 25'b1111100000011001001000101; // loading 30 into R12
		#20 ControlWord <= 25'b0111101100111101001010001; //subtracting R15-R12, goes to R30
		
		#20 constant <= 64'b0;
		ControlWord <= 25'b0000100010000000101000110; //M5 gets R2, 5 is stored in R1
		
		#10 constant <= 64'd200;
		ControlWord <= 25'b11111000001011011001000101; // loading 200 into R22
		#20 ControlWord <= 25'b1011000000111001001000110;
	end
	
	always begin
		#1 clock <= ~clock;
	end
	
	DatapathLEGv8 dut (ControlWord, status, constant, data, clock, reset);	
	RegFile32x64 dutReg (A, B, D, DA, SA, SB, W, reset, clock);
	
	assign R5 = dut.regfile.R05;
	assign R2 = dut.regfile.R02;
	assign R0 = dut.regfile.R00;
	assign R30 = dut.regfile.R30;
	assign R15 = dut.regfile.R15;
	assign R12 = dut.regfile.R12;
	assign R1 = dut.regfile.R01;
	assign R28 = dut.regfile.R28;
	assign R22 = dut.regfile.R22;
	assign R3 = dut.regfile.R03;
	
	//RAM256x64 dutRAM (address, clock, in, write, out);
	//assign M5 = dut.data_mem.MEM_output;


endmodule
