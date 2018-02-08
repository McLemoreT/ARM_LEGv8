module DatapathLEGv8 (ControlWord, status, constant, data, clock, reset);
	input [34:0] ControlWord;
	input [63:0] constant; 
	inout [63:0] data;
	input clock, reset;
	output [3:0] status;
	
	wire [4:0] SA, SB, DA; //selectA, selectB, and data address
	wire RegWrite, MemWrite;
	wire [63:0] RegAbus, RegBbus;
	wire [4:0] FS; //funciton select
	wire C0;
	wire [63:0] ALU_output, MEM_output;
	wire EN_Mem, EN_ALU;
	
	assign {SA, SB, DA, RegWrite, MemWrite, FS, C0, EN_Mem, EN_ALU} = ControlWord; //control word consists of these values
	
	RegFile32x64 regfile (RegAbus, RegBbus, data, DA, SA, SB, RegWrite, reset, clock); //Head's order of these values was different, but I changed the order to match or RegFile
	
	ALU_LEGv8 alu (RegAbus, RegBbus, FS, C0, ALU_output, status); //in our ALU module, we had CO, not C0
	
	RAM256x64 data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	
	assign data = EN_Mem ? MEM_output : 64'bz; //tristate buffers. Outbut is data.
	assign data = EN_ALU ? ALU_output : 64'bz; //If EN_ALU is 1, data gets ALU_output. If EN_ALU is 0, data gets 64 bit high impedance.
	
	
endmodule
