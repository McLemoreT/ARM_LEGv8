module ALU_testbench (); //written 2/4/18
		//ALU input/outputs: A, B, FS, CO, F, status
	
	reg [63:0] A, B; //2 main inputs for ALU
	wire [63:0]F; //answer output of ALU
	wire [3:0]status; //status signalfrom ALU
	reg [4:0]FS;	//Ainvert (FS[0]), Binvert (FS[1]), and function selector for ALU (FS[4:2])
		//FS[4:2] funcitons are: 000 AND, 001 OR, 010 ADD, 011 xor, 100 shift left, 101 shift right	
		//note that when FS[4:0] = 11000 and beyond, output should be all zeroes, because it's undefined
	reg CO; //carry in?


	initial begin
		FS <= 5'b0;
    	CO <= 1'b0;
		A <= {$random, $random};
		B <= {$random, $random};
		#320 $stop; //then stop once all possibilities have been tested (will happen at #320)
	end

	always begin
		#5 FS <= FS + 1'b1; //every 5 ticks
		A <= {$random, $random};
		B <= {$random, $random};
	end
	
	always begin
		#160 CO <= CO + 1'b1; //after it has finished testing all operations with where CO=0, make CO=1 and redo all calculations
	end
	
	ALU_LEGv8 dut (A, B, FS, CO, F, status); //instantiating ALU module
	


endmodule
