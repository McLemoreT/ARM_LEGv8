module CLA_16bit(
    output [15:0] S,
    output PG,GG,
    input [15:0] A,B,
    input Cin
    );
	wire [3:0] G,P,C;
	 
	 
	 CLA_4bit u0 (S[3:0], P[0], G[0], A[3:0], B[3:0], Cin);
 	 CLA_4bit u1 (S[7:4], P[1], G[1], A[7:4], B[7:4], C[0]);
 	 CLA_4bit u2 (S[11:8], P[2], G[2], A[11:8], B[11:8], C[1]);
 	 CLA_4bit u3 (S[15:12], P[3], G[3], A[15:12], B[15:12], C[2]);
    
 
  //  assign G = A & B; //Generate
  //  assign P = A ^ B; //Propagate
   // assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) |(P[3] & P[2] & P[1] & P[0] & C[0]);
  //  assign S = P ^ C;
    assign PG = P[3] & P[2] & P[1] & P[0];
    assign GG = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
endmodule
