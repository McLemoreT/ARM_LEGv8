module ProgramCounter(PC, PC4, in, PS, clock, reset);
	input [63:0]in;
	input [1:0]PS; // Program counter function Select bits
/*
	PS |
	---+----------------
	00 | PC <- PC
	01 | PC <- PC + 4
	10 | PC <- in
	11 | PC <- PC + 4 +in*4
	*/
	input clock, reset;
	output [63:0]PC;
	output [63:0]PC4;
	
	wire [63:0] PC_in; // input to program counter / output from mux
	wire [63:0] AdderOut; // output of offeset adder
	wire load_PC;
	assign load_PC = 1'b1;
	assign PC4 = PC + 4; // +4 adder
	assign AdderOut = PC4 + {in[63:1], 2'b00};
	Mux4to1Nbit PC_Mux (PC_in, PS, PC, PC4, in, AdderOut);
	defparam PC_Mux.N = 64;
	RegisterNbit PC_Reg (PC, PC_in, load_PC, reset, clock);
	defparam PC_Reg.N = 64;
endmodule
