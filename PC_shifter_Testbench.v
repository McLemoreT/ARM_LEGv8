module shifter_Testbench();
			
			reg [63:0] A;
			
			reg [2:0] shift_amount;
			wire [63:0] Left;  //
			
			//reg [63:0] out;
			
			
			initial begin
			A <= 64'd5;
			#50 $stop;
			shift_amount =  3'd2;
			
			end
			
			always begin
			#5 A = A +1;
			#5 shift_amount = 3'd2;
	
			end
				
				PC_Shifter dut (A, shift_amount, Left);

			 
endmodule 
			 
			 
			
			
			
			
			
