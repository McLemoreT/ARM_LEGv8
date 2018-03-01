module PC (clock, load, reset, PC_out); 
	input clock, load, reset;
	output [63:0] PC_out;
	
	reg [63:0] PC4;
	wire [63:0] PC_out;
	
	RegisterNbit Register(PC_out, PC4, load, reset, clock);
	
	
	always @ (posedge clock) begin
	PC4 <= PC_out + 4;
	end


	
	
endmodule
