module Mux2to1Nbit (F, S, I0, I1)
parameter N = 64;
input S;
input [N-1:0] I0, I1;

output reg [N-1:0] F;


always @(*) begin
	case (S)
		1'b0: F <= I0;
		1'b1: F <= I1;
	endcase	
end

endmodule
