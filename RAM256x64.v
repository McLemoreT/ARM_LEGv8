module RAM256x64 (address, clock, in, write, out);
	input [7:0] address; 
	input clock;
	input [63:0] in;
	input write;
	output reg [63:0] out;
	
	reg [63:0] mem [0:255]; //creating 2-dimensional object. Calling to memory on DE0
	//width         length
	
	always @(posedge clock) begin	
		if (write) begin
			mem[address] <= in;	//if write signal, the memory at specified address gets written
		end
	end
	
	always @(posedge clock) begin
		out <= mem[address];	//output of RAM gets data from specified location
	end
	
endmodule 
