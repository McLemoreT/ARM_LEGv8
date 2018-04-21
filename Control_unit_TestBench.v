module control_unit_TestBench();


reg [31:0] instruction;

reg [3:0] status;
reg clock, reset;

wire [95:0] control_word;

wire [63:0] K;



initial begin

reset <= 1;
clock <= 0;
#165 $stop;

end

always begin

#1 reset <= 0;
#10 instruction <= 32'h91002841; 

#10 instruction<= 32'hF8001061;

#10 instruction <= 32'hF84013E9;

 #10 instruction <=32'hD360442C; // LSL X12, X1, 17
//11010011011000000100010000101100

#10 instruction <=32'h910003E7; // ADDI X7, XZR, 0
//10010001000000000000001111100111

#10 instruction <=32'hF100C8FF; // SUBIS XZR, X7, 50
//11110001000000001100100011111111

 #10 instruction <=32'h54000082; // B.HS 4
//1010100000000000000000010000010
#10 instruction <=32'hF84000F7; // LDUR X23, [X7, 0]
//11111000010000000000000011110111

#10 instruction <=32'b11111000000000110010000011110111; // STUR X23, [X7, 50]
#10 instruction <=32'b10010001000000000000010011100111; // ADDI X7, X7, 1
#10 instruction <=32'b00010111111111111111111111111010; // B -6

end 

always begin

#5 clock <= ~clock;

end
 
  control_unit_setup  dut (instruction, status, reset, clock, control_word, K);
 //Simulation of Single Decoder to verify functionality
//D_decoder dut2 (instruction, control_word);

endmodule

