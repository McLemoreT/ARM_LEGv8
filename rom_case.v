module rom_case(out, address);
//connect PC[17:2] to the address input
	output reg [31:0] out;
	input  [15:0] address; // address- 16 deep memory  
	always @(address) begin
		case (address)
			16'h0000: out = 32'h91002841; // ADDI X1, X2, 10
					//100100010000000000000010100001000001

			16'h0001: out = 32'hF8001061; // STUR X1, [X3, 1]
					//11111000000000000001000001100001

			16'h0002: out = 32'hF84013E9; // LDUR X9, [XZR, 1]
					//11111000010000000001001111101001

			16'h0003: out = 32'hD360442C; // LSL X12, X1, 17
					//11010011011000000100010000101100

			16'h0004: out = 32'h910003E7; // ADDI X7, XZR, 0
					//10010001000000000000001111100111

			16'h0005: out = 32'hF100C8FF; // SUBIS XZR, X7, 50
					//11110001000000001100100011111111

			16'h0006: out = 32'h54000082; // B.HS 4
					//1010100000000000000000010000010

			16'h0007: out = 32'hF84000F7; // LDUR X23, [X7, 0]
					//11111000010000000000000011110111

			16'h0008: out = 32'b11111000000000110010000011110111; // STUR X23, [X7, 50]
			16'h0009: out = 32'b10010001000000000000010011100111; // ADDI X7, X7, 1
			16'h000A: out = 32'b00010111111111111111111111111010; // B -6
			default:  out = 32'hD60003E0; // BR XZR
		endcase
	end
endmodule

/* Instantiation in Data Path:
// ROM            (   out      address)
	rom_case prog_mem (ROM_output, PC[17:2]);
	// since LEGv8 is supposed to be byte addressable and the ROM is 4-byte addressable
	// I drop the lower two address bits and pass in the next 16
*/
	