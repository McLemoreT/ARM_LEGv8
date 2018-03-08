module PC_out_testbench (); 
wire [63:0] PC_out;
reg clock, load, reset;
reg [1:0]PS;
wire [63:0] PC4;
reg [63:0]X;
wire [63:0] Adder_Out;

	initial begin
		load <= 0;
		clock <= 0;
		X <= 64'd10;
		reset <= 1;
		#5 reset <= 0;
		PS = 2'b00;
		#100 $stop; //then stop
	end
	
	always begin
		#10 load <= 1'b1; 
//		X <= X + 3;
//	#5  load <= 1'b0;
//		#5 PS <= 2'b01;
		#20 PS <= 2'b10;
//		#5 PS <= 2'b11;
	end
	
	always begin
		#1 clock <= ~clock;
	end
	
	PC dut (clock, load, reset, PS, X, PC_out);	

	assign PC4 = dut.PC4;
	assign Adder_Out = dut.Adder_Out;
	//assign mux1Out = dut.mux1Out;
	
endmodule
