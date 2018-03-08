module PC (clock, load, reset, PS, X, PC_out); 
	input clock, load, reset;
	input [1:0]PS;
	
	input [63:0] X;
	output [63:0]PC_out;
	
	//wire [63:0] PC4;
	reg [63:0] PC4;
	wire [63:0] PC_out; 
	wire [63:0]PC_in;	
	
	reg [63:0]Adder_Out;

	
	wire [63:0]mux1Out;
	



	
	RegisterNbit Register(PC_out, PC_in, load, reset, clock);
	/*
	initial begin
		X <= 64'd10;
	end
	*/
	
	
	always @ (posedge clock) begin
		PC4 <= PC_out + 4;
		
		//PC_in <= mux1Out;
	end
	
	
	always @ (posedge clock) begin
		Adder_Out <= PC4 + X;
	end
	
	assign PC_in = PS[1] ? Adder_Out : PC4;	
	
	


	
	
endmodule
