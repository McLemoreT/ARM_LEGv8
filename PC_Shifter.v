module PC_Shifter(A, shift_amount, left);
			
			input [63:0]A;
			input [2:0]shift_amount;
			output [63:0]left;
			
			
			//wire [2:0]shift_amount;
		   // assign shift_amount =  3'd4;
			assign left = A << shift_amount;

endmodule
			