module Datapath_testbench (); 
			

wire [63:0] R5, R2, R0, R30, R15, R12, R1, R28, R22;

wire [63:0] data;
reg [63:0] constant;
reg [24:0] ControlWord;
reg clock, reset;
wire [3:0] status;

wire [63:0] M5, M200;


	initial begin
		constant <= 64'd0;
		ControlWord <= 25'b0;
		reset <= 1;
		clock <= 0;

		#165 $stop; //then stop
	end
//Control word is defined as: {SA, SB, DA, RegWrite, MemWrite, FS, Bsel, EN_Mem, EN_ALU} = ControlWord;
	always begin
		#5 reset <= 0;
		#5 constant <= 64'd4;

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

		#10 ControlWord <= 25'b0111101100111101001010001; //subtracting R15-R12, goes to R30
		//------------------------------------

		#10 constant <= 64'd5;
		ControlWord <= 25'b1111100000000011001000101; // loading 5 into R1
		#10 constant <= 64'd7;
		ControlWord <= 25'b1111100000000101001000101; // loading 7 into R2
		#10 constant <= 64'd0;
		ControlWord <= 25'b0000100010000000101000110; //M5 gets R2, (5 is the memory address, stored in R1)
		
		#10 constant <= 64'd200;
		ControlWord <= 25'b1111100000101101001000101; // loading 200 into R22
		#10 constant <= 64'd18;
		ControlWord <= 25'b1111100000000001001000101; // loading 18 into R0 (arbitrary register)
		#10 constant <= 64'd0;
		ControlWord <= 25'b1011000000000000101000110; //M200 gets 18 (18 was stored in R28)
		#10 ControlWord <= 25'b1011000000111001001000110; //R28 get value 18 which is stored in M200
		#20 reset <= 1;

	end
	
	always begin
		#1 clock <= ~clock;
	end
	
	DatapathLEGv8 dut (ControlWord, status, constant, data, clock, reset);	
  
	//viewing the necessary register locations in Modelsim
	assign R0 = dut.regfile.R00;	
	assign R1 = dut.regfile.R01;	
	assign R2 = dut.regfile.R02;	
	assign R5 = dut.regfile.R05;
	assign R12 = dut.regfile.R12;
	assign R15 = dut.regfile.R15;
	assign R22 = dut.regfile.R22;
	assign R28 = dut.regfile.R28;
	assign R30 = dut.regfile.R30;	

	//viewing the necessary memory locations in Modelsim
	assign M5 = dut.data_mem.mem[5];
	assign M200 = dut.data_mem.mem[200];


endmodule
