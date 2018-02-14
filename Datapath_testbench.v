module Datapath_testbench (); 
			
/*	reg [63:0] A, B; //2 main inputs for ALU
	wire [63:0]F; //answer output of ALU
	wire [3:0]status; //status signalfrom ALU
	reg [4:0]FS;	//Ainvert (FS[0]), Binvert (FS[1]), and function selector for ALU (FS[4:2])
		//FS[4:2] funcitons are: 000 AND, 001 OR, 010 ADD, 011 xor, 100 shift left, 101 shift right	
		//note that when FS[4:0] = 11000 and beyond, output should be all zeroes, because it's undefined
	reg CO; //carry in?*/


reg [63:0] data;
reg [63:0] constant;
reg [24:0] ControlWord;
reg clock, reset;
reg [3:0] status;
	
	initial begin
		constant <= 64'd0;
		ControlWord <= 25'b0;
		reset <= 0;
		clock <= 0;
		data <= 0;
		#30 $stop; //then stop once all possibilities have been tested
	end

	always begin
		#10 data <= 64'd256;
		ControlWord <= 25'b0000100010000001000000000;
		#20 ControlWord <= 25'b0000000000000000000000000;
	end
	
	always begin
		#5 clock <= ~clock;
	end
	
	DatapathLEGv8 dut (ControlWord, status, constant, data, clock, reset); //instantiating datapath module
	


endmodule
