module Mux8to1Nbit (F, S, I0, I1, I2, I3, I4, I5, I6, I7);
	parameter N = 64;
	input [N-1:0] I0, I1, I2, I3, I4, I5, I6, I7;
	input [3:0] S;
	output [N-1] F;
	
	assign F = S[2] ? (S[1] ? (S[0] ? I7:I6):(S[0] ? I5:I4)) : (S[1] ? (S[0] ? I3:I2):(S[0] ? I1:I0));
	
	endmodule
