
module DatapathLEGv8(/*ControlWord, status, data,*/ clock, reset);
//	input [96:0] ControlWord;
//	inout [63:0] data;
	input clock, reset;
//	output [4:0] status;
	
	wire [4:0] status;
	wire [63:0] data;
	wire [96:0] ControlWord;
	wire [63:0]address;
	wire EN_B;	
	wire [63:0] PC4;
	wire [63:0] constant;
	wire [4:0] SA, SB, DA;
	wire [63:0] RegAbus, RegBbus, B;
	wire [4:0] FS;
	wire [63:0] ALU_output, MEM_output;
	wire EN_Mem, EN_ALU;
	wire Bsel;
	wire [3:0] ALU_Status;
	wire [1:0] PS;
	wire EN_PC, SL, WM, WR; 
	wire [63:0] A;
	wire [63:0] constant2;
	wire [31:0] instruction;
	
	assign {NS, constant, EN_PC, EN_Mem, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B} = ControlWord; //we have the control word, pull all these things off of it in the correct order
													    //Removed NS so CW went from 94 bits to 93
	assign RegAbus = PCsel ? constant : A;
	assign RegBbus = Bsel ? constant : B;
														 
	RegFile32x64 regfile(A, B, data, DA, SA, SB, WR, reset, clock);

	ALU_LEGv8 alu (A, RegBbus, FS, FS[1], ALU_output, ALU_Status);

	
	RegisterNbit statusReg (status[4:1], ALU_Status, SL, reset, clock); //SL is part of control work. need to figure out how to get that here
	defparam statusReg.N = 4;
	
	assign status[0] = ALU_Status[0];
	
	//RAM256x64sim data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	//RAM256x64m9k data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	//RAM256x64 data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	
	//RAM256x64 data_mem (ALU_output, ~clock, RegBbus, MemWrite, MEM_output); 
		//clock is inverted so ALU operations happen before reading values. Gives time for fan-in time
	RAM256x64 data_mem (ALU_output, ~clock, data, WM, MEM_output);

	//defparam data_mem.memory_words = 7000;
	assign data = (EN_PC) ? PC4 : 64'bz;
	assign data = EN_Mem ? MEM_output : 64'bz;
	assign data = EN_ALU ? ALU_output : 64'bz;

	assign data = EN_B ? B : 64'bz;
	
	ProgramCounter PC (address, PC4, RegAbus, PS, clock, reset);
	
	
	rom_case ROM (instruction, address[17:2]);
    
	control_unit_setup c1 (instruction, status, reset, clock, ControlWord, constant2);

	
endmodule
