module quad_7seg_decoder(in, hex3, hex2, hex1, hex0);
	input [15:0] in;
	output [6:0] hex3, hex2, hex1, hex0;
	
	seven_seg_hex dec0 (in[3:0], hex0);
	seven_seg_hex dec1 (in[7:4], hex1);
	seven_seg_hex dec2 (in[11:8], hex2);
	seven_seg_hex dec3 (in[15:12], hex3);
endmodule

module seven_seg_hex (bin, hex);
	input [3:0]bin;
	output [6:0]hex;
	reg [6:0]hex;
	
	always @(bin) begin
		case (bin)
			4'b0000: hex = 7'b0111111;
			4'b0001: hex = 7'b0000110;
			4'b0010: hex = 7'b1011011;
			4'b0011: hex = 7'b1001111;
			4'b0100: hex = 7'b1100110;
			4'b0101: hex = 7'b1101101;
			4'b0110: hex = 7'b1111101;
			4'b0111: hex = 7'b0000111;
			4'b1000: hex = 7'b1111111;
			4'b1001: hex = 7'b1100111;
			4'b1010: hex = 7'b1110111;
			4'b1011: hex = 7'b1111100;
			4'b1100: hex = 7'b0111001;
			4'b1101: hex = 7'b1011110;
			4'b1110: hex = 7'b1111001;
			4'b1111: hex = 7'b1110001;
		endcase
	end
	
endmodule