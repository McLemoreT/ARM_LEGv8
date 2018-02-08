module CLA_64bit(
    output [63:0] S,
    output Cout,
    input [63:0] A,B,
    input Cin
    );
	 wire [3:0] G,P,C;
	 
	 
	 CLA_16bit u0 (S[15:0], P[0], G[0], A[15:0], B[15:0], Cin);
 	 CLA_16bit u1 (S[31:16], P[1], G[1], A[31:16], B[31:16], C[1]);
 	 CLA_16bit u2 (S[47:32], P[2], G[2], A[47:32], B[47:32], C[2]);
 	 CLA_16bit u3 (S[63:48], P[3], G[3], A[63:48], B[63:48], C[3]);
    

   // assign C[0] = Cin;
    assign C[0] = G[0] | (P[0] & C[0]);
    assign C[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) |(P[3] & P[2] & P[1] & P[0] & C[0]);
    //assign S = P ^ C;
    //assign PG = P[3] & P[2] & P[1] & P[0];
    //assign GG = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
endmodule
