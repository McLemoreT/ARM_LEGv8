module LEGv8_core(clock, reset, data, address, en_read, en_write, instruction, PC, r0, r1, r2, r3, r4, r5, r6, r7, instruction_sel, instruction_user /*, read_address, reg_or_mem*/);
	input clock, reset;
	inout [63:0] data;
	output [63:0] address;
	inout en_read, en_write;	//was output
	output [15:0] r0, r1, r2, r3, r4, r5, r6, r7; // outputs for visualization
	output [15:0] PC;
	output [31:0]instruction; // for visualization
	input instruction_sel;
	input [31:0]instruction_user;
//	input [4:0] read_address;
//	input reg_or_mem;
	wire [30:0]control_word;
	wire [63:0]constant;
	wire [4:0]status;
	
//	control_unit_setup CU (instruction, status, reset, clock, control_word, constant);
	
	DatapathLEGv8 datapath (control_word, constant, status, instruction, data, address, en_write, en_read, clock, reset, PC, r0, r1, r2, r3, r4, r5, r6, r7, instruction_sel, instruction_user /*, read_address, reg_or_mem*/);

endmodule
