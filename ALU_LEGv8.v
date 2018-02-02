module ALU_LEGv8 (A, B, FS, CO, F, status); //from class
	input [63:0] A, B;
	input CO;
	input [4:0] FS; 	//using one select input FS with multiple bits to act select input to each mux
							//FS[0] = Ainvert, FS[1] = Binvert, FS[4:2] = function select (for big output mux)
							//FS[4:2] funcitons are: 000 AND, 001 OR, 010 ADD, 011 xor, 100 shift left, 101 shift right
	output [63:0]F;
	output [3:0] status;
	
	wire [63:0] A_signal, B_signal;
	assign A_signal = FS[0] ? ~A : A; //mux selectign between A or ~A
	assign B_signal = FS[1] ? ~B : B; //...B or ~B

	wire Z, N, C, V;
	assign status = {V, C, N, Z}; //set N (negative) and Z (zero) as LSBs becaseu they are used least often
	assign N = F[63];
	assign Z = (F == 64'b0) ? 1'b1 : 1'b0;
	assign V = ~(A_signal[63] ^ B_signal[63]) & (F[63] ^ A_signal[63]);
	
	wire [63:0] and_out, or_out, xor_out, add_out, shift_left, shift_right;
	assign and_out = A_signal & B_signal;
	assign or_out = A_signal | B_signal;
	assign xor_out = A_signal ^ B_signal;
	
	Adder adder_inst (A_signal, B_signal, CO, add_out, C); //instantiating adder module, should it be Adder64bit?

	Shifter shift_inst (A, B[5:0], shift_left, shift_right);

	Mux8to1Nbit main_mux (F, FS[4:2], and_out, or_out, add_out, xor_out, shift_left, shift_right, 64'b0, 64'b0);
	

endmodule
