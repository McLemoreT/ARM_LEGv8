//`define CW_BITS 96

module control_unit_setup(instruction, status, reset, clock, control_word, K);
	input [31:0] instruction;
							  // registerd   , instant
	input [4:0] status; // {V, C, N, Z}, Z
	input reset, clock;
	output [96:0] control_word;
	output [63:0] K;
	
	wire V, C, N, Z, ZZ;
	wire [10:0] opcode;
	assign opcode = instruction[31:21];
	
	// partial control words
	wire [96:0] branch_cw, other_cw;
	wire [96:0] D_format_cw, I_arithmetic_cw, I_logic_cw, IW_cw, R_ALU_cw;
	wire [96:0] B_cw, B_cond_cw, BL_cw, CBZ_cw, BR_cw;
	
	// state logic
	wire NS;
	assign NS = control_word[95];
	reg state;
	always @(posedge clock or posedge reset) begin
		if(reset)
			state <= 1'b0;
		else
			state <= NS;
	end
	
	// partial control unit decoders
	D_decoder dec0_000 (instruction, D_format_cw);
	I_arithmetic_decoder dec0_010 (instruction, I_arithmetic_cw);
	I_logic_decoder dec0_100 (instruction, I_logic_cw);
	IW_decoder dec0_101 (instruction, state, IW_cw);
	R_ALU_decoder dec0_110 (instruction, R_ALU_cw);
	B_decoder dec1_000 (instruction, B_cw);
	B_cond_decoder dec1_010 (instruction, status[4:1], B_cond_cw);
	BL_decoder dec1_100 (instruction, BL_cw, state);
	CBZ_decoder dec1_101 (instruction, status[0], CBZ_cw);
	BR_decoder dec1_110 (instruction, BR_cw);
	
	// 2:1 mux to select between branch instructions and all others
	assign control_word = opcode[5] ? branch_cw : other_cw;
	
	// 8:1 mux to select between branch insturctions
	Mux8to1Nbit2 branch_mux (branch_cw, opcode[10:8], 
		B_cw, 0, B_cond_cw, 0, BL_cw, CBZ_cw, BR_cw, 0);
	defparam branch_mux.N = 97;
	
	// 8:1 mux to select between all other insturctions
	Mux8to1Nbit2 other_mux (other_cw, opcode[4:2], 
		D_format_cw, 0, I_arithmetic_cw, 0, I_logic_cw, IW_cw, R_ALU_cw, 0);
	defparam other_mux.N = 97;
	assign K = control_word[94:31];
	
endmodule

module D_decoder (I, control_word);
	input [31:0]I;
	output [96:0] control_word;
	
		// wire for all control signals
	wire [4:0] DA, SA, SB;
	wire [63:0] K;
	wire [1:0] PS;
	wire [4:0] FS;
	wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	
//	assign {V, C, N, Z} = status;
	assign DA = I[4:0];
	assign SA = I[9:5];
	assign SB = I[4:0]; //"I think" Matt
	assign K = {55'b0, I[20:12]};
	assign FS = 5'b01000;
	assign PCsel = 1'b0; //Kin
	assign Bsel = 1'b1;
	assign SL = 1'b0;
	assign EN_RAM = I[22];
	assign EN_PC = 1'b0;		//This might be wrong
	assign EN_B = ~I[22];
	assign EN_ALU = 1'b0;
	assign WM = ~I[22];
	assign WR =  I[22];
	assign NS = 1'b0;
	assign PS = 2'b01;

	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B};
endmodule

module I_arithmetic_decoder (I, control_word);
	input [31:0]I;
	output [96:0] control_word;
	
		// wire for all control signals
	wire [4:0] DA, SA, SB;
	wire [63:0] K;
	wire [1:0] PS;
	wire [4:0] FS;
	wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	
	assign DA = I[4:0];
	assign SA = I[9:5];
	assign SB = 5'b0; //"I think" Matt
	assign K = {52'b0, I[21:10]};
	assign FS = {3'b010, I[30], 1'b0};
	assign PCsel = 1'b0; //Kin
	assign Bsel = 1'b1;
	assign SL = I[29];
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b0;		//This might be wrong
	assign EN_B = 1'b0;
	assign EN_ALU = 1'b1;
	assign WM = 1'b0;
	assign WR =  1'b1;
	assign NS = 1'b0;
	assign PS = 2'b01;

	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B};

endmodule

module I_logic_decoder (I, control_word); //Minor problems
	input [31:0]I; 
	output [96:0] control_word;
	
	wire [4:0] DA, SA, SB;    
    wire [63:0] K;
    wire [1:0] PS;
    wire [4:0] FS;
    wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	

	assign DA = I[4:0];
	assign SA = I[9:5];
	assign SB = 5'b0;
	assign K = {52'b0, I[21:10]};		
	assign FS = {1'b0, I[30] & ~I[29], I[30]^I[29], 2'b00};
	assign PCsel = 1'b1; //Don't know what Kin does.
	assign Bsel = 1'b1;
	assign SL = I[30] & I[29];
	assign EN_ALU = 1'b1;
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b0;
	assign WM = 1'b0;
	assign WR = 1'b1;
	assign NS = 1'b0;
	assign EN_B = 1'b0;
	assign PS = 2'b01;
	
	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B};
endmodule

module IW_decoder (I, state, control_word);
	input [31:0]I;
	input state;
	output [96:0] control_word;
	
	// wire for all control signals
	wire [4:0] DA, SA, SB;
	wire [63:0] K;
	wire [1:0] PS;
	wire [4:0] FS;
	wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	
	// easy stuff first
	assign DA = I[4:0];
	assign SB = 5'b0;
	assign Bsel = 1'b1;
	assign PCsel = 1'b0;
	assign SL = 1'b0;
	assign EN_ALU = 1'b1;
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b0;
	assign WM = 1'b0;
	assign WR = 1'b1;
	assign EN_B = 1'b0;
	
	// hard ones
	wire I29_Snot;
	assign I29_Snot = I[29] & ~state;
	assign SA = I[29] ? I[4:0] : 5'd31;
	assign K = (I29_Snot) ? 64'hFFFFFFFFFFFF0000 : {48'b0, I[20:5]};
	assign PS = {1'b0, ~I29_Snot};
	assign FS = {2'b00, ~I29_Snot, 2'b00};
	assign NS = I29_Snot;
	
	
	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B};
endmodule

module R_ALU_decoder (I, control_word);
	input [31:0]I;
	output [96:0] control_word;
	
	// wire for all control signals
	wire [4:0] DA, SA, SB;
	wire [63:0] K;
	wire [1:0] PS;
	wire [4:0] FS;
	wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	
//	assign {V, C, N, Z} = status;
	assign DA = I[4:0];
	assign SA = I[9:5];
	assign SB = I[20:16];
	assign K = {58'b0, I[15:10]};
	assign FS[1] = I[24] & ~I[22] & I[30];
	assign FS[0] = 1'b0;
	assign FS[2] = ~I[24] & (I[30] ^ I[29]) | I[24] & I[22] & ~I[21];
	assign FS[3] = ~I[24] & I[30] & ~I[29] | I[24] & ~I[22];
	assign FS[4] = I[24] & I[22];
	
	assign PCsel = 1'b0; //Don't know what Kin does. // Still don't understand why this is 1, 4/10/2018 Tuesday 8:51PM EST 08028 Glassboro NJ USA North America Earth SOL Milky Way 
	assign Bsel = I[22];
	assign SL = ~I[24] & I[30] & I[29] | I[24] & ~I[22] & I[29];
	assign EN_ALU = 1'b1;
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b0;
	assign WM = 1'b0;
	assign WR = 1'b1;
	assign NS = 1'b0;
	assign EN_B = 1'b0;
	assign PS = 2'b01;
	
	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B};
endmodule

module B_decoder (I, control_word);
	input [31:0]I;
	output [96:0] control_word;

	wire [4:0] DA, SA, SB;
   wire [63:0] K;
   wire [1:0] PS;
   wire [4:0] FS;
   wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
    
 //   assign {V, C, N, Z} = status;

   assign DA = 5'b0; // not used
   assign SA = 5'b0;
   assign SB = 5'b0; // not used
	assign FS = 5'b0;
   assign Bsel = 1'b0;
   assign PCsel = 1'b0;
   assign PS = 2'b11;
   assign SL = 1'b0;
   assign EN_ALU = 1'b0;
   assign EN_RAM = 1'b0;
   assign EN_PC = 1'b0;
   assign WM = 1'b0;
	assign WR = 1'b0;
	assign EN_B = 1'b0;
	assign NS = 1'b0;
	assign K = {38'b0, I[25:0]};
	
	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B};
endmodule

module B_cond_decoder (I, status, control_word);
	input [31:0]I;
	input [4:0]status;
	output [96:0] control_word;
		//wire all control signals 03/28/2018
	wire[4:0] DA, SA, SB;
	wire[63:0] K;
	wire [1:0] PS;
	wire [4:0] FS;
	wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	wire V, C, N, Z, ZZ;
	
	assign {V, C, N, Z, ZZ} = status;
	assign DA = 5'b0;
	assign SA = 5'b0;
	assign SB = 5'b0;
	assign K = {{45{I[23]}},I[23:5]};
	assign FS = 5'b0;
	assign PCsel = 1'b1; //Kin
	assign Bsel = 1'b0;
	assign SL = 1'b0;
	assign EN_ALU = 1'b0;
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b0;
	assign WM = 1'b0;
	assign WR = 1'b0;
	assign NS = 1'b0;
	assign EN_B =1'b0;	
	/*PS
	PC + 4 			when condition is false
	PC + 4 + in*4	when condition is true
	
	PS |
	---+----------------
	00 | PC <- PC
	01 | PC <- PC + 4
	10 | PC <- in
	11 | PC <- PC + 4 +in*4
	For this function, Ps[0] is always 1
	*/
	
	wire PCmux_out;
	wire Zn_C, N_xnor_V, N_xnor_V_Zn;
	assign Zn_C = ~Z & C;
	assign N_xnor_V = ~(N^V);
	assign N_xnor_V_Zn = N_xnor_V & ~Z;
	Mux8to1Nbit PC1mux (PCmux_out, I[3:1], Z, C, N, V, Zn_C, N_xnor_V, N_xnor_V_Zn, ~I[0]);
	defparam PC1mux.N = 1; 
	assign PS[1] = PCmux_out ^ I[0];
	assign PS[0] = 1'b1;
	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B};
	
endmodule

module BL_decoder (I, control_word, state);
	input [31:0]I;
	input state;
	output [96:0] control_word;
	
	wire [4:0] DA, SA, SB;    
	wire [63:0] K;
	wire [1:0] PS;
	wire [4:0] FS;
	wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	
	assign DA = 5'b11110;	//register 30 is dedicated to this ...i think
	assign SA = 5'b0;
	assign SB = 5'b0;
	assign PCsel = 1'b1;
	assign K = {{38{I[25]}}, I[25:0]};
	assign SL = 1'b0;
	assign EN_ALU = 1'b0;
	assign EN_RAM = 1'b0;
	assign EN_PC = ~state;
	assign WM = 1'b0;
	assign WR = state;
	assign Bsel = 1'b0;
	assign NS = ~state;
	assign PS = {state, state};
	assign FS = 5'b0;
	assign EN_B = 1'b0;
	
	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B};
	

endmodule

module CBZ_decoder (I, status, control_word);
	input [31:0]I;
	input [4:0]status; //only need status[0] 4/12/2018
	output [96:0] control_word;
	
	wire [4:0] DA, SA, SB;    
   wire [63:0] K;
   wire [1:0] PS;
   wire [4:0] FS;
   wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	wire V, C, N, Z, ZZ;
	
	assign {V, C, N, Z, ZZ} = status;
	assign DA = 5'b0;
	assign SA = I[4:0];
	assign SB = I[4:0];
	assign K = {{45{I[23]}},I[23:5]};
	assign PS = ZZ? {~I[24], 1'b1} : {I[24], 1'b1};
	assign FS = 5'b00100;
	assign PCsel = 1'b1; //Don't know what Kin does.
	assign Bsel = 1'b0;
	assign SL = 1'b1; //Possibly doesn't matter since we are using ZZ which is routed around the register N bit 4/19/2018
	assign EN_ALU = 1'b0;
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b0;
	assign WM = 1'b0;
	assign WR = 1'b0;
	assign NS = 1'b0;
	assign EN_B = 1'b0;
	
	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B};
	
	
endmodule

module BR_decoder (I, control_word);
	input [31:0]I;
	output [96:0] control_word;
	
	wire [4:0] DA, SA, SB;    
	wire [63:0] K;
	wire [1:0] PS;
	wire [4:0] FS;
	wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	
	assign DA = 5'b0;
	assign SA = I[4:0];
	assign SB = 5'b0;
	assign PCsel = 1'b1;
	assign K = 64'b0;
	assign SL = 1'b0	;
	assign EN_ALU = 1'b0;
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b0;
	assign WM = 1'b0;
	assign WR = 1'b0;
	assign Bsel = 1'b0;
	assign NS = 1'b0;
	assign PS = 2'b10;	
	assign FS = 5'b0;
	assign EN_B = 1'b0;
	
	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B};
	
	
endmodule


module Mux8to1Nbit2(F, S, I0, I1, I2, I3, I4, I5, I6, I7);
			parameter N = 97;
			
			input [96:0] I0, I1, I2, I3, I4, I5, I6, I7;
			input [2:0]S; 
			output [96:0]F;
			
			
			assign F = S[2] ? (S[1] ? (S[0] ? I7:I6): (S[0] ? I5:I4)) : (S[1] ? (S[0] ? I3:I2): (S[0] ? I1:I0));
			
			
		endmodule
			

