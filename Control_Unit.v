`define CW_BITS 94

module control_unit_setup(instruction, status, reset, clock, control_word, K);
	input [31:0] instruction;
							  // registerd   , instant
	input [4:0] status; // {V, C, N, Z}, Z
	input reset, clock;
	output [`CW_BITS-1:0] control_word;
	output [63:0] K;
	
	wire [10:0] opcode;
	assign opcode = instruction[31:21];
	
	// partial control words
	wire [`CW_BITS:0] branch_cw, other_cw;
	wire [`CW_BITS:0] D_format_cw, I_arithmetic_cw, I_logic_cw, IW_cw, R_ALU_cw;
	wire [`CW_BITS:0] B_cw, B_cond_cw, BL_cw, CBZ_cw, BR_cw;
	
	// state logic
	wire NS;
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
	BL_decoder dec1_100 (instruction, BL_cw);
	CBZ_decoder dec1_101 (instruction, status, CBZ_cw);
	BR_decoder dec1_110 (instruction, BR_cw);
	
	// 2:1 mux to select between branch instructions and all others
	assign control_word = opcode[5] ? branch_cw : other_cw;
	
	// 8:1 mux to select between branch insturctions
	Mux8to1Nbit branch_mux (branch_cw, opcode[10:8], 
		B_cw, 0, B_cond_cw, 0, BL_cw, CBZ_cw, BR_cw, 0);
	defparam other_mux.N = `CW_BITS+1;
	
	// 8:1 mux to select between all other insturctions
	Mux8to1Nbit other_mux (other_cw, opcode[4:2], 
		D_format_cw, 0, I_arithmetic_cw, 0, I_logic_cw, IW_cw, R_ALU_cw, 0);
	defparam branch_mux.N = `CW_BITS+1;
	
endmodule

module D_decoder (I, control_word);
	input [31:0]I;
	output [`CW_BITS-1:0] control_word;
	
//	assign {V, C, N, Z} = status;
	assign DA = I[4:0];
	assign SA = I[10:5];
	assign SB = 5'b0;
	assign K = {45{I[23],I[23:5]}};
	assign FS = 5'b0;
	assign PCsel = 1'b0; //Kin
	assign Bsel = 1'b0;
	assign SL = 1'b0;
	assign EN_ALU = 1'b0;
	assign EN_RAM = 1'b1;
	assign EN_PC = 1'b1;		//This might be wrong
	assign WM = ~I[22];
	assign WR =  I[22];
	assign NS = 1'b0;
	
endmodule

module I_arithmetic_decoder (I, control_word);
	input [31:0]I;
	output [`CW_BITS-1:0] control_word;
	
	   //wire all control signals - put into all of this small modules
    wire [4:0] DA, SA, SB;    
    wire [63:0] K;
    wire [1:0] PS;
    wire [4:0] FS;
    wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
    
    //specific to this module:
    wire Z, N, C, V;
    
 //   assign {V, C, N, Z} = status;
    assign DA = I[4:0];    //Rt
    assign SA = I[9:5];//Rn
    assign SB = 5'b0;
    assign K = {52{I[21], I[21:10]}};    //the 45 of the MSBs of I sign extends K to 64 bits
 /*  always @(*) begin
       case(I[30])
           1'b0: FS = 5'b00010;
           1'b1: FS = 5'b01010;
			 endcase
	end*/
	
	assign FS = {1'b0, I[30], 3'b010};
/*	FS[4] = 1'b0;
	FS[3] = I[30];
	FS[2:0] = 3'b010;*/
	
	
	
endmodule

module I_logic_decoder (I, control_word); //Minor problems
	input [31:0]I; 
	output [`CW_BITS-1:0] control_word;
	
	wire [4:0] DA, SA, SB;    
    wire [63:0] K;
    wire [1:0] PS;
    wire [4:0] FS;
    wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	
//	assign {V, C, N, Z} = status;
	assign DA = I[4:0];
	assign SA = I[9:5];
	assign SB = 5'b0;
	assign K = {52{I[21],I[21:10]}};
/*	always @(*) begin
	case(I[30:29])//31 down 30? PAdding at begining or end?
		2'b00:	FS = 5'b00000;
		2'b01:	FS = 5'b00100;
		2'b10:	FS = 5'b01100;
		2'b11:	FS = 5'b00000;
		endcase
		end */
		
	assign FS = {1'b0, I[30] & ~I[29], I[30]^I[29], 2'b00};
		
	assign PCsel = 1'b1; //Don't know what Kin does.
	assign Bsel = 1'b1;
	assign SL = I[30] & I[29];
	assign EN_ALU = 1'b1;
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b1;
	assign WM = 1'b0;
	assign WR = 1'b1;
	assign NS = 1'b0; //I don't even know what this is
endmodule

module IW_decoder (I, state, control_word);
	input [31:0]I;
	input state;
	output [`CW_BITS:0] control_word;
	
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
	
	// hard ones
	wire I29_Snot;
	assign I29_Snot = I[29] & ~state;
	assign SA = I[29] ? I[4:0] : 5'd31;
	assign K = (I29_Snot) ? 64'hFFFFFFFFFFFF0000 : {48'b0, I[20:5]};
	assign PS = {1'b0, ~I29_Snot};
	assign FS = {2'b00, ~I29_Snot, 2'b00};
	assign NS = I29_Snot;
	
	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA};
endmodule

module R_ALU_decoder (I, control_word);
	input [31:0]I;
	output [`CW_BITS:0] control_word;
	
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
	assign K = 1'b0;
	assign FS[0] = I[24] & ~I[22] & I[30];
	assign FS[1] = 1'b0;
	assign FS[2] = ~I[24] & (I[30] ^ I[29]) | I[24] & I[22] & ~I[21];
	assign FS[3] = ~I[24] & I[30] & ~I[29] | I[24] & ~I[22];
	assign FS[4] = I[24] & I[22];
	
	assign PCsel = 1'b1; //Don't know what Kin does. // Still don't understand why this is 1, 4/10/2018 Tuesday 8:51PM EST 08028 Glassboro NJ USA North America Earth SOL Milky Way 
	assign Bsel = 1'b0;
	assign SL = ~I[24] & I[30] & I[29] | I[24] & ~I[22] & I[29];
	assign EN_ALU = 1'b1;
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b1;
	assign WM = 1'b0;
	assign WR = 1'b1;
	assign NS = 1'b0;
	
endmodule

module B_decoder (I, control_word); // DOn't understand how PC works. Can't really solve this one given all the unknowns.
//Possibly only arithmetic 
	input [31:0]I;
	output [`CW_BITS-1:0] control_word;

	wire [4:0] DA, SA, SB;
   wire [63:0] K;
   wire [1:0] PS;
   wire [4:0] FS;
   wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
    
 //   assign {V, C, N, Z} = status;

   assign DA = 5'b0; // not used
   assign SA = 5'b0;
   assign SB = 5'b0; // not used
   assign Bsel = 1'b1;
   assign PCsel = 1'b0;
   assign PS = 2'b11;
   assign SL = 1'b0;
   assign EN_ALU = 1'b1;
   assign EN_RAM = 1'b0;
   assign EN_PC = 1'b1;
   assign WM = 1'b0;
   assign WR = 1'b1;
endmodule

module B_cond_decoder (I, status, control_word);
	input [31:0]I;
	input [3:0]status;
	output [`CW_BITS:0] control_word;
		//wire all control signals 03/28/2018
	wire[4:0] DA, SA, SB;
	wire[63:0] K;
	wire [1:0] PS;
	wire [4:0] FS;
	wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	
	assign {V, C, N, Z} = status;
	assign DA = 5'b0;
	assign SA = 5'b0;
	assign SB = 5'b0;
	assign K = {45{I[23],I[23:5]}};
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
	wire Zn_C, N_xor_V, N_xor_V_Zn;
	assign Zn_C = ~Z & C;
	assign N_xnor_V = ~(N^V);
	assign N_xnor_V_Zn = N_xor_V & ~Z;
	Mux8to1Nbit PC1mux (PCmux_out, I[3:1], Z, C, N, V, Zn_C, N_xnor_V, N_xnor_V_Zn, ~I[0]);
	defparam PC1mux.N = 1; 
	assign PS[1] = PCmux_out ^ I[0];
	assign control_word = {NS, K, EN_PC, EN_RAM, EN_ALU,PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA};
	
endmodule

module BL_decoder (I, control_word);
	input [31:0]I;
	output [`CW_BITS-1:0] control_word;
	
	wire [4:0] DA, SA, SB;    
	wire [63:0] K;
	wire [1:0] PS;
	wire [4:0] FS;
	wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	
	assign DA = 5'b11110;	//register 30 is dedicated to this ...i think
	assign SA = 5'b0;
	assign SB = 5'b0;
	assign PCsel = 1'b1;
	assign K = {38{I[25], I[25:0]}};
	assign SL = 1'b0;
	assign EN_ALU = 1'b0;
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b1;
	assign WM = 1'b0;
	assign WR = 1'b1;
	assign Bsel = 1'b0;
	assign NS = 1'b0;
	assign PS = 2'b11;
	assign FS = 5'b0;


endmodule

module CBZ_decoder (I, status, control_word);
	input [31:0]I;
	input [4:0]status; //only need status[0] 4/12/2018
	output [`CW_BITS-1:0] control_word;
	
	wire [4:0] DA, SA, SB;    
    wire [63:0] K;
    wire [1:0] PS;
    wire [4:0] FS;
    wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	
	assign {V, C, N, Z} = status;
	assign DA = I[4:0];
	assign SA = 5'b0;
	assign SB = 5'b0;
	assign K = {45{I[23],I[23:5]}};
	assign PS = 2'b11;
	assign FS = 5'b0;
	assign PCsel = 1'b1; //Don't know what Kin does.
	assign Bsel = 1'b1;//Maybe not depending on PCsel
	assign SL = 1'b0;
	assign EN_ALU = 1'b00;
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b1;
	assign WM = 1'b0;
	assign WR = 1'b0;
	assign NS = 1'b0;
	
endmodule

module BR_decoder (I, control_word);
	input [31:0]I;
	output [`CW_BITS-1:0] control_word;
	
	wire [4:0] DA, SA, SB;    
	wire [63:0] K;
	wire [1:0] PS;
	wire [4:0] FS;
	wire PCsel, Bsel, SL, EN_ALU, EN_RAM, EN_PC, WM, WR, NS;
	
	assign DA = 5'b0;
	assign SA = 5'b0;
	assign SB = 5'b0;
	assign PCsel = 1'b0;
	assign K = 64'b0;
	assign SL = 1'b0;
	assign EN_ALU = 1'b1;
	assign EN_RAM = 1'b0;
	assign EN_PC = 1'b1;
	assign WM = 1'b0;
	assign WR = 1'b1;
	assign Bsel = 1'b0;
	assign NS = 1'b0;
	assign PS = 2'b10;	//PC should get Rn
	assign FS = 5'b0;
	
endmodule


