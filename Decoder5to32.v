module Decoder5to32(S, m);
	input [4:0]S; // select
	output [31:0]m; // minterm outputs
	
	assign m[0] = ~S[4] &~S[3] &~S[2] &~S[1] &~S[0];
	assign m[1] = ~S[4] &~S[3] &~S[2] &~S[1] & S[0];
	assign m[2] = ~S[4] &~S[3] &~S[2] & S[1] &~S[0];
	assign m[3] = ~S[4] &~S[3] &~S[2] & S[1] & S[0];
	assign m[4] = ~S[4] &~S[3] & S[2] &~S[1] &~S[0];
	assign m[5] = ~S[4] &~S[3] & S[2] &~S[1] & S[0];
	assign m[6] = ~S[4] &~S[3] & S[2] & S[1] &~S[0];
	assign m[7] = ~S[4] &~S[3] & S[2] & S[1] & S[0];
	assign m[8] = ~S[4] & S[3] &~S[2] &~S[1] &~S[0];
	assign m[9] = ~S[4] & S[3] &~S[2] &~S[1] & S[0];
	assign m[10] =~S[4] & S[3] &~S[2] & S[1] &~S[0];
	assign m[11] =~S[4] & S[3] &~S[2] & S[1] & S[0];
	assign m[12] =~S[4] & S[3] & S[2] &~S[1] &~S[0];
	assign m[13] =~S[4] & S[3] & S[2] &~S[1] & S[0];
	assign m[14] =~S[4] & S[3] & S[2] & S[1] &~S[0];
	assign m[15] =~S[4] & S[3] & S[2] & S[1] & S[0];
	assign m[16] = S[4] &~S[3] &~S[2] &~S[1] &~S[0];
	assign m[17] = S[4] &~S[3] &~S[2] &~S[1] & S[0];
	assign m[18] = S[4] &~S[3] &~S[2] & S[1] &~S[0];
	assign m[19] = S[4] &~S[3] &~S[2] & S[1] & S[0];
	assign m[20] = S[4] &~S[3] & S[2] &~S[1] &~S[0];
	assign m[21] = S[4] &~S[3] & S[2] &~S[1] & S[0];
	assign m[22] = S[4] &~S[3] & S[2] & S[1] &~S[0];
	assign m[23] = S[4] &~S[3] & S[2] & S[1] & S[0];
	assign m[24] = S[4] & S[3] &~S[2] &~S[1] &~S[0];
	assign m[25] = S[4] & S[3] &~S[2] &~S[1] & S[0];
	assign m[26] = S[4] & S[3] &~S[2] & S[1] &~S[0];
	assign m[27] = S[4] & S[3] &~S[2] & S[1] & S[0];
	assign m[28] = S[4] & S[3] & S[2] &~S[1] &~S[0];
	assign m[29] = S[4] & S[3] & S[2] &~S[1] & S[0];
	assign m[30] = S[4] & S[3] & S[2] & S[1] &~S[0];
	assign m[31] = S[4] & S[3] & S[2] & S[1] & S[0];
endmodule
