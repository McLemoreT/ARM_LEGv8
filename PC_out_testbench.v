module PC_out_testbench (); 
wire [63:0] PC_out;
reg clock, load, reset;

	initial begin
		load <= 0;
		clock <= 0;
		#5 reset <= 1;
		#5 reset <= 0;
			
		#50 $stop; //then stop
	end
	
	always begin
	#10 load <= 1'b1;
	#5  load <= 1'b0;
		
	end
	
	always begin
		#1 clock <= ~clock;
	end
	
	PC dut (clock, load, reset, PC_out);	


endmodule
