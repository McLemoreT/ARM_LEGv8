module Overflow_Detector (Zero, Neg, C_out, OverFlow, A);
    input [63:0] A;
    output reg Zero, Neg, C_out, OverFlow;
	 
always @(*) begin
	case(A)//Case to check if the input is Zero or if there is an OverFlow
		8'o00000000: Zero <= 1'b1;//Checks to see if A is '00000000' in octal. 
		8'o00000000: OverFlow <= 1'b1;
		
	default
		Zero <= 1'b0;
	endcase
	
	case([63]A)//Case to check if the input is Negative, most significant bit would be 1 is negative
		1'b1: Neg <= 1'b1;
	default
		Neg <= 1'b0;
	endcase
end
endmodule
