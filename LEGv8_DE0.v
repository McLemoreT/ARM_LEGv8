module LEGv8_DE0(CLOCK_50, SW, LEDG, BUTTON, GPIO1_D, GPIO0_D, HEX0, HEX1, HEX2, HEX3);
	input CLOCK_50;
	input [9:0] SW;
	input [2:0] BUTTON;
	output [9:0] LEDG;
	output [63:0] GPIO1_D; // address bus
	inout [63:0] GPIO0_D; // data bus
	output [6:0] HEX0, HEX1, HEX2, HEX3;
//	input [31:0] DIP_SW;


//clock_div clock4Hz (CLOCK_50, clock);
//	clock_div2 clock25MHz (CLOCK_50, clock);
	wire clock, reset;
	tri [63:0] data;
	tri [63:0] portA;
	wire [63:0] address;
	wire read, write;
	reg [9:0]counter;
//	assign clock = ~BUTTON[2];
//	wire clock45;
	pll pll_inst(CLOCK_50, clock);
//	assign clock = clock45; //counter[0];
	assign reset = ~BUTTON[0];
	assign write = BUTTON[1];	//write when button not pressed
	assign read = ~write;		//read when button pressed
	wire [4:0]read_address;
	wire reg_or_mem, instruction_sel;
	wire [31:0] instruction_user;
	
//	assign reg_or_mem = ~SW[0];	//if button pressed, put B from reg onto data bus to read, else mem gets on data bus to be read
//	assign read_address = ~SW[4:0];
	
	
	always @(posedge CLOCK_50)
		counter = counter + 1'b1;
	
	// wires of outputs for visualizations
	wire [31:0] instruction;
	wire [15:0] PC, r0, r1, r2, r3, r4, r5, r6, r7;
	
	assign instruction_sel = ~BUTTON[1]; //if button pressed, instruction comes form user input
//	assign instruction_user[31:0] = DIP_SW[31:0];
	assign instruction_user[9:0] = SW[9:0];	//custom instruction specified by user on DE0
	assign instruction_user[31:10] = 22'b1101001101100000000001;	//hardcoding beginning of instruction for LSL X20, X20, 1

	
	LEGv8_core dut (clock, reset, data, address, read, write, instruction, PC, r0, r1, r2, r3, r4, r5, r6, r7, instruction_sel, instruction_user /*, read_address, reg_or_mem*/);
	
	GPIO_Peripheral portA_inst (clock, reset, portA, data, address, read, write);
	
	wire [6:0] h0, h1, h2, h3, h4, h5, h6, h7;
	wire [6:0] hex0, hex1, hex2, hex3;
	quad_7seg_decoder address_decoder (address[15:0], h7, h6, h5, h4);
	quad_7seg_decoder data_decoder (data[15:0], h3, h2, h1, h0);
	quad_7seg_decoder pc_decoder (PC[15:0], hex3, hex2, hex1, hex0);
	wire [31:0] DIP_SW; // not used
	// invert hex's for PC (the ones on the DE0)
	assign HEX0 = ~hex0;
	assign HEX1 = ~hex1;
	assign HEX2 = ~hex2;
	assign HEX3 = ~hex3;
	GPIO_Board gpio_board (
	CLOCK_50, // connect to CLOCK_50 of the DE0
	r0, r1, r2, r3, r4, r5, r6, r7, // row display inputs
	h0, 1'b0, h1, 1'b0, // hex display inputs
	h2, 1'b0, h3, 1'b0, 
	h4, 1'b0, h5, 1'b0, 
	h6, 1'b0, h7, 1'b0, 
	DIP_SW, // 32x DIP switch output
	instruction, // 32x LED input
	GPIO0_D, // (output) connect to GPIO0_D
	GPIO1_D // (input/output) connect to GPIO1_D
	);
	
	// connect lower 10 bits of portA to LEDs and next 10 to switches
	assign LEDG[9:0] = portA[9:0];
	
	assign portA[19:10] = read ? SW[9:0] : 10'bz;
	
endmodule

module clock_div(clock_in, clock_out);
	input clock_in;
	output reg clock_out;
	
	reg [23:0] count;
	
	always @(posedge clock_in) begin
		if(count < 12500000)
			count <= count + 1'b1;
		else
			count <= 24'b0;
			
		clock_out <= (count < 6250000) ? 1'b1 : 1'b0;
	end

endmodule	



