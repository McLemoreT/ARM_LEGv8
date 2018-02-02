module Adder (A, B, Cin, S, Cout);
	input [63:0] A, B;
	input Cin;
	output [63:0] s;
	output Cout;

assign {Cout, S} = A + B + Cin;


endmodule
