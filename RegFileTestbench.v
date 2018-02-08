module RegFileTestbench();
	wire [63:0] A, B;
	reg [63:0] D;
	reg [4:0] DA, SA, SB;
	reg W, reset, clock;
	wire [63:0] R00, R01, R02, R03, R04, R05, R06, R07, R08, R09,
					R10, R11, R12, R13, R14, R15, R16, R17, R18, R19,
					R20, R21, R22, R23, R24, R25, R26, R27, R28, R29,
					R30, R31;
					
	RegFile32x64 dut (A, B, D, DA, SA, SB, W, reset, clock);
	
	initial begin
		clock <= 1'b0;
		reset <= 1'b1;
		DA <= 5'd0;
		SA <= 5'd31;
		SB <= 5'd30;
		W <= 1'b1;
		D <= 64'h0123456789ABCDEF; //randon arbitrary inital value
		#4 reset <= 1'b0; //after 4 processor clocks, reset to 0
		#320 W <= 1'b0; //after 320 processor clocks, turn off write
		#320 $stop;
	end
	
	always begin
		#5 clock <= ~clock;
	end
	
	always begin
		#10 DA <= DA + 1'b1; //every 10 ticks, the data address changes to next register
		SA <= SA + 1'b1; //increment select bits
		SB <= SB + 1'b1;
		D <= {$random, $random};
	end
	
	assign R00 = dut.R00;
	assign R01 = dut.R01;
	assign R02 = dut.R02;
	assign R03 = dut.R03;
	assign R04 = dut.R04;
	assign R05 = dut.R05;
	assign R06 = dut.R06;
	assign R07 = dut.R07;
	assign R08 = dut.R08;
	assign R09 = dut.R09;
	assign R10 = dut.R10;
	assign R11 = dut.R11;
	assign R12 = dut.R12;
	assign R13 = dut.R13;
	assign R14 = dut.R14;
	assign R15 = dut.R15;
	assign R16 = dut.R16;
	assign R17 = dut.R17;
	assign R18 = dut.R18;
	assign R19 = dut.R19;
	assign R20 = dut.R20;
	assign R21 = dut.R21;
	assign R22 = dut.R22;
	assign R23 = dut.R23;
	assign R24 = dut.R24;
	assign R25 = dut.R25;
	assign R26 = dut.R26;
	assign R27 = dut.R27;
	assign R28 = dut.R28;
	assign R29 = dut.R29;
	assign R30 = dut.R30;
	assign R31 = dut.R31;
endmodule




