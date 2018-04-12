module DatapathLEGv8(ControlWord, status, constant, data, clock, reset);
	input [24:0] ControlWord;
	input [63:0] constant;
	inout [63:0] data;
	input clock, reset;
	output [3:0] status;
	
	wire [4:0] SA, SB, DA;
	wire RegWrite, MemWrite;
	wire [63:0] RegAbus, RegBbus, B;
	wire [4:0] FS;
	wire [63:0] ALU_output, MEM_output;
	wire EN_Mem, EN_ALU;
	wire Bsel;
	
	assign {SA, SB, DA, RegWrite, MemWrite, FS, Bsel, EN_Mem, EN_ALU} = ControlWord;
	
	RegFile32x64 regfile(RegAbus, B, data, DA, SA, SB, RegWrite, reset, clock);
	
	assign RegBbus = Bsel ? constant : B;
	
	ALU_LEGv8 alu (RegAbus, RegBbus, FS, FS[0], ALU_output, status);
	
	//RAM256x64sim data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	//RAM256x64m9k data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	RAM256x64 data_mem (ALU_output, ~clock, RegBbus, MemWrite, MEM_output);
	
	
	//defparam data_mem.memory_words = 7000;
	
	assign data = EN_Mem ? MEM_output : 64'bz;
	assign data = EN_ALU ? ALU_output : 64'bz;
	
endmodule
