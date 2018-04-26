module GPIO_Peripheral(clock, reset, pins, data, address, read, write);
	parameter PORT_ADDRESS = 64'h10000000;// 0001 0000 0000 0000 0000 0000 0000 0000
	parameter DIR_ADDRESS = 64'h10000008; // 0001 0000 0000 0000 0000 0000 0000 1000
	inout [63:0]pins;
	inout [63:0]data;
	input [63:0]address;
	input clock, reset, read, write;
	
	// detect if address is PORT_ADDRESS
	wire port_detect;
	wire dir_detect;
	assign port_detect = (address == PORT_ADDRESS) ? 1'b1 : 1'b0;
	assign dir_detect = (address == DIR_ADDRESS) ? 1'b1 : 1'b0;
	
	// register wires
	wire [63:0] port_out, dir_out;
	wire port_load, dir_load;
	wire port_enable, dir_enable;
	assign port_load = port_detect & write;
	assign dir_load = dir_detect & write;
	assign port_enable = port_detect & read;
	assign dir_enable = dir_detect & read;
	
	RegisterNbit port_reg (port_out, data, port_load, reset, clock);
	defparam port_reg.N = 64;
	RegisterNbit dir_reg (dir_out, data, dir_load, reset, clock);
	defparam dir_reg.N = 64;
	
	assign data = port_enable ? pins : 64'bz;
	assign data = dir_enable ? dir_out : 64'bz;
	
	genvar i;
	generate
	for (i = 0; i < 64 ; i = i + 1) begin: PIN_GEN
		 assign pins[i] = dir_out[i] ? port_out[i] : 1'bz;
	end
	endgenerate
	
endmodule
