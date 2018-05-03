module RegFile32x64(A, B, D, DA, SA, SB, W, reset, clock, r0, r1, r2, r3, r4, r5, r6, r7);
	output [63:0]A, B; // output buses
	output [15:0] r0, r1, r2, r3, r4, r5, r6, r7;
	input [63:0]D; // data input
	input [4:0]DA; // destination data address
	input [4:0]SA; // select address for A bus
	input [4:0]SB; // select address for B bus
	input W; // write enable
	input reset; // asynchronous
	input clock; // posedge
	
	wire [63:0] R00, R01, R02, R03, R04, R05, R06, R07, R08, R09,
					R10, R11, R12, R13, R14, R15, R16, R17, R18, R19,
					R20, R21, R22, R23, R24, R25, R26, R27, R28, R29,
					R30, R31; 
					
/*	assign r6 = R20[63:48];
	assign r5 = R20[47:32];
	assign r4 = R20[31:16];
	assign r3 = R20[15:0];*/
	
	wire [31:0]L, m; // load wires and minterm wires
	
	RegisterNbit reg0 (R00, D, L[0], reset, clock);
	RegisterNbit reg1 (R01, D, L[1], reset, clock);
	RegisterNbit reg2 (R02, D, L[2], reset, clock);
	RegisterNbit reg3 (R03, D, L[3], reset, clock);
	RegisterNbit reg4 (R04, D, L[4], reset, clock);
	RegisterNbit reg5 (R05, D, L[5], reset, clock);
	RegisterNbit reg6 (R06, D, L[6], reset, clock);
	RegisterNbit reg7 (R07, D, L[7], reset, clock);
	RegisterNbit reg8 (R08, D, L[8], reset, clock);
	RegisterNbit reg9 (R09, D, L[9], reset, clock);
	RegisterNbit reg10 (R10, D, L[10], reset, clock);
	RegisterNbit reg11 (R11, D, L[11], reset, clock);
	RegisterNbit reg12 (R12, D, L[12], reset, clock);
	RegisterNbit reg13 (R13, D, L[13], reset, clock);
	RegisterNbit reg14 (R14, D, L[14], reset, clock);
	RegisterNbit reg15 (R15, D, L[15], reset, clock);
	RegisterNbit reg16 (R16, D, L[16], reset, clock);
	RegisterNbit reg17 (R17, D, L[17], reset, clock);
	RegisterNbit reg18 (R18, D, L[18], reset, clock);
	RegisterNbit reg19 (R19, D, L[19], reset, clock);
	RegisterNbit reg20 (R20, D, L[20], reset, clock);
	RegisterNbit reg21 (R21, D, L[21], reset, clock);
	RegisterNbit reg22 (R22, D, L[22], reset, clock);
	RegisterNbit reg23 (R23, D, L[23], reset, clock);
	RegisterNbit reg24 (R24, D, L[24], reset, clock);
	RegisterNbit reg25 (R25, D, L[25], reset, clock);
	RegisterNbit reg26 (R26, D, L[26], reset, clock);
	RegisterNbit reg27 (R27, D, L[27], reset, clock);
	RegisterNbit reg28 (R28, D, L[28], reset, clock);
	RegisterNbit reg29 (R29, D, L[29], reset, clock);
	RegisterNbit reg30 (R30, D, L[30], reset, clock);
	assign R31 = 64'b0;
	
	Decoder5to32 D_decoder (DA, m);
	
	assign L = m & {W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W};
	
	Mux32to1Nbit A_mux (A, SA, R00, R01, R02, R03, R04, R05, R06, R07, R08, R09,
								      R10, R11, R12, R13, R14, R15, R16, R17, R18, R19,
								      R20, R21, R22, R23, R24, R25, R26, R27, R28, R29,
								      R30, R31);
										
	Mux32to1Nbit B_mux (B, SB, R00, R01, R02, R03, R04, R05, R06, R07, R08, R09,
								      R10, R11, R12, R13, R14, R15, R16, R17, R18, R19,
								      R20, R21, R22, R23, R24, R25, R26, R27, R28, R29,
								      R30, R31);
										
	defparam A_mux.N = 64;
	defparam B_mux.N = 64;
	
	assign r0 = R00;
	assign r1 = R01;		
	assign r2 = R02;
	assign r3 = R03;
	assign r4 = R04;
	assign r5 = R05;
	assign r6 = R06;
	assign r7 = R07;
endmodule







