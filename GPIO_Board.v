// NOTE: This module follows the Version 2 Labeling of the GPIO Board

// This module will display the input values on the DE0 GPIO BOARD
// It requires the DE0 CLOCK_50 signal to be connected to it's clock input
// R* and HEX* inputs can just use whatever data should be displayed.
// The DIP_SW output will hold the value of the 32 DIP switches
// The LEDS input will display the data on the 32 LEDs 
// The GPIO_0 output should be connected to GPIO0_D (all 32 bits are used)
// The GPIO_1 input/output should be connected to GPIO1_D (all 32 bits are used)
// This module works by selecting 1 of eight rows/7-seg displays at a time
// and multiplexing through the desired output signals.
module GPIO_Board(
	clock_50, // connect to CLOCK_50 of the DE0
	R0, R1, R2, R3, R4, R5, R6, R7, // row display inputs
	HEX0, HEX0_DP, HEX1, HEX1_DP, // hex display inputs
	HEX2, HEX2_DP, HEX3, HEX3_DP, 
	HEX4, HEX4_DP, HEX5, HEX5_DP, 
	HEX6, HEX6_DP, HEX7, HEX7_DP, 
	DIP_SW, // 32x DIP switch output
	LEDS, // 32x LED input
	GPIO_0, // (output) connect to GPIO0_D
	GPIO_1 // (input/output) connect to GPIO1_D
	);
	// if desiring to use the display (Matrix/Hex) portion of the GPIO board 
	// without the LEDs/Switches to free up GPIO pins then plug the GPIO board 
	// in to the GPIO1 header only and connect GPIO1_D from the top level to
	// GPIO_0 of the module and connect 32'bZ to GPIO_1 of the module
	
	// inputs to control the Matrix and Hex displays
	input [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
	input [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	input HEX0_DP, HEX1_DP, HEX2_DP, HEX3_DP, HEX4_DP, HEX5_DP, HEX6_DP, HEX7_DP;
	// input for 50MHz clock
	input clock_50;
	// input to control the 32 LEDs
	input [31:0] LEDS;
	// outputs from the DIP switches (updated every 2.6ms or 380Hz)
	output [31:0] DIP_SW;
	// output to GPIO0 for controlling the Matrix/Hex displays
	output [31:0]GPIO_0;
	// input/output to GPIO1 for reading the switches and controlling the LEDs
	inout wire [31:0] GPIO_1;
	
	
	// create a 17 bit counter to manage the timing of displaying the information
	// bits 16:14 will be used at the 3 bit row counter / signal multiplexer select
	// bits 13:11 will be used to disable the row output right before and right after
	// the counter changes. This is to avoid ghosting on the display caused by hardware
	// switching delay
	reg [16:0]count;
	wire [2:0]count3bit;
	// 17 bit counter
	initial
		count <= 17'b0;
	
	always @(posedge clock_50)
		count <= count + 1'b1;
	
	// create a logic circuit which will output a 0 when count[13:11] are 000 or 111
	// this signal will used to select between the row output and 0  in order to 
	// disable the row output when the count3bit is close to changing.
	wire row_gate;
	// comment out this line and uncomment the next line to see what ghosting looks like
	assign row_gate = (count[13:11] == 3'b0 || count[13:11] == 3'b111) ? 1'b0 : 1'b1;
	//assign row_gate = 1'b1;
	
	assign count3bit = count[16:14];
	
	// use a 16 bit 8:1 MUX to select between the row input signals (R0 to R7)
	wire [15:0] matrix_columns2, matrix_columns;
	// output the mux to matrix_columns2 and then flip the order of the bits to display the
	// binary value with the LSb on the right
	gpio_mux_8_to_1 matrix_mux(matrix_columns2, count3bit, R7, R6, R5, R4, R3, R2, R1, R0);
	defparam matrix_mux.n = 16; // make it a 16 bit mux
	// flip the bits using a gererate block, the generate block instructs
	// the compiler to create code, it is code creating code. Very useful
	// when the same thing has to be done repeatedly
	generate // start generate code block
	genvar c; // variable used only for generating code
	// loop 16 times to generate 16 assignment statements
	for(c = 0; c < 16; c = c + 1) begin : col_gen // for loops in generate blocks must have labels
		assign matrix_columns[c] = matrix_columns2[15-c];
	end // end the loop
	endgenerate // end the generate block
	
	// use a 8-bit 8:1 MUX to select between hex input signals (HEX0 to HEX7)
	// concatenate the decimal point input with the 7-segment signal to make a 8-bit signal
	wire [7:0] hex_segments;
	gpio_mux_8_to_1 hex_mux(hex_segments, count3bit, 
		{HEX7_DP, HEX7}, {HEX6_DP, HEX6}, 
		{HEX5_DP, HEX5}, {HEX4_DP, HEX4}, 
		{HEX3_DP, HEX3}, {HEX2_DP, HEX2}, 
		{HEX1_DP, HEX1}, {HEX0_DP, HEX0});
	defparam hex_mux.n = 8; // make it a 8 bit mux
	
	// use a 3-to-8 decoder to select which row to power based on the count3bit value
	wire [7:0]rowa;
	gpio_decoder_3_8 row_dec(count3bit, rowa[0], rowa[1], rowa[2], rowa[3], rowa[4], rowa[5], rowa[6], rowa[7]);
	// select (mux) between the row output of the decoder and 0 using the
	// row_gate signal which will disable the row output when close
	// to switching
	wire [7:0]row;
	assign row = row_gate ? rowa : 8'b0;
	
	// connect the signals to the GPIO0 output
	assign GPIO_0 = {hex_segments, matrix_columns, row};
	
	// make a temporary output that will be connected to GPIO_1
	// the majority of the time the output should drive the GPIO_1
	// pins with the LEDS input data but for a small fraction of a
	// second the it should switch to high-impedance (Z) so the
	// GPIO_1 pins can be read to get the switch value.
	// While in high-impedance the switch value will drive the LEDs 
	// so it is important that this time be as short as possible
	// but long enough that the switch signals can be properly read.
	wire [31:0] output_to_leds;
	// the 10 bit count[16:7] will be 0 for 1/1024 of the time or
	// 2.56us every 2.6ms giving a 2.56us window where the switches
	// control the pins instead of the LEDS input signal
	assign output_to_leds = (count[16:7] == 0) ? 32'bZ : LEDS;
	
	// use a subset of the 17 bit counter to trigger a read from the
	// DIP switches. The entire 17 bit counter has a frequency of
	// ~380 Hz and period of 2.6ms, count[6] has a frequency of
	// ~375kHz and count[16:6] == 1 will occur exactly halfway 
	// through the 2.56us period where the switches control the
	// GPIO1 pins.
	reg [31:0] input_from_switches;
	always @(posedge count[6]) begin
		if(count[16:6] == 1) begin
			// sample the switches 320ns after the output is turned to high-impedance
			input_from_switches <= GPIO_1; 
		end
	end
	
	// flip the output_to_leds and connect it to GPIO_1
	// flip the input_from_switches and connect it to DIP_SW
	// using a generate block to generate the 32 lines of code needed to flip the bits
	generate
	genvar i;
	for(i = 0; i < 32; i = i + 1) begin : gen1
		assign GPIO_1[i] = output_to_leds[31-i];
		assign DIP_SW[i] = input_from_switches[31-i];
	end
	endgenerate
		
endmodule

// 8 to 1 mux (default to 8 bits)
module gpio_mux_8_to_1(F, S, x0, x1, x2, x3, x4, x5, x6, x7);
	parameter n = 8;
	input [2:0] S;
	input [n-1:0] x0, x1, x2, x3, x4, x5, x6, x7;
	output [n-1:0] F;
	
	assign F = (S[2] ? (S[1] ? (S[0] ? x7 : x6) : (S[0] ? x5 : x4)) : (S[1] ? (S[0] ? x3 : x2) : (S[0] ? x1 : x0)));
endmodule

// 3-8 decoder
module gpio_decoder_3_8(S, m0, m1, m2, m3, m4, m5, m6, m7);
	input [2:0]S;
	output m0, m1, m2, m3, m4, m5, m6, m7;
	
	assign m0 = ~S[2] & ~S[1] & ~S[0];
	assign m1 = ~S[2] & ~S[1] &  S[0];
	assign m2 = ~S[2] &  S[1] & ~S[0];
	assign m3 = ~S[2] &  S[1] &  S[0];
	assign m4 =  S[2] & ~S[1] & ~S[0];
	assign m5 =  S[2] & ~S[1] &  S[0];
	assign m6 =  S[2] &  S[1] & ~S[0];
	assign m7 =  S[2] &  S[1] &  S[0];
endmodule

