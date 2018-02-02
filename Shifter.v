module Shifter (A, shift_amount, left, right); //from class
	input [63:0] A;
	input [5:0] shift_amount;
	output [63:0] left, right;
	
	assign left = A << shift_amount;
	assign right = A >> shift_amount;

endmodule
