module DatapathLEGv8(ControlWord, status, constant, data, clock, reset);
	input [24:0] ControlWord;
	input [63:0] constant;
	inout [63:0] data;
	input clock, reset;
	output [4:0] status;
	
	wire [4:0] SA, SB, DA;
	wire RegWrite, MemWrite;
	wire [63:0] RegAbus, RegBbus, B;
	wire [4:0] FS;
	wire [63:0] ALU_output, MEM_output;
	wire EN_Mem, EN_ALU;
	wire Bsel;
	wire [3:0] ALU_Status;
	
	assign {SA, SB, DA, RegWrite, MemWrite, FS, Bsel, EN_Mem, EN_ALU} = ControlWord;
	
	RegFile32x64 regfile(RegAbus, B, data, DA, SA, SB, RegWrite, reset, clock);
	
	assign RegBbus = Bsel ? constant : B;
	
	ALU_LEGv8 alu (RegAbus, RegBbus, FS, FS[0], ALU_output, ALU_Status);
	
	RegisterNbit statusReg (status[4:1], ALU_Status, SL, reset, clock); //SL is part of control work. need to figure out how to get that here
	defparam statusReg.N = 4;
	
	assign status[0] = ALU_Status[0];
	
	//RAM256x64sim data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	//RAM256x64m9k data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	//RAM256x64 data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	
	//RAM256x64 data_mem (ALU_output, ~clock, RegBbus, MemWrite, MEM_output); 
		//clock is inverted so ALU operations happen before reading values. Gives time for fan-in time
	RAM256x64 data_mem (ALU_output, ~clock, B, MemWrite, MEM_output);

	//defparam data_mem.memory_words = 7000;
	
	assign data = EN_Mem ? MEM_output : 64'bz;
	assign data = EN_ALU ? ALU_output : 64'bz;
	
	ProgramCounter PC (PC, PC4, in, PS, clock, reset);
    
    	rom_case ROM (instruction, address);
    
	control_unit_setup c1 (instruction, status, reset, clock, control_word, K)
	
endmodule
