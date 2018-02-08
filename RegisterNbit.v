module RegisterNbit(Q, D, load, reset, clock);
	parameter N = 64;
	
	input load; // positive logic
	input reset; // asynchronous positive logic
	input clock; // positive edge
	input [N-1:0]D; // data input
	output reg [N-1:0]Q;
	
	always @(posedge clock or posedge reset) begin
		if(reset)
			Q <= 0;
		else if(load)
			Q <= D;
		else
			Q <= Q;
	end
endmodule
