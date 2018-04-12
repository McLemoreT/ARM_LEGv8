module CLA_testbench (); //written 2/4/18
		//ALU input/outputs: A, B, FS, CO, F, status
	
	reg [63:0] A, B; //2 main inputs for ALU
	reg Cin;
	
	wire [63:0] Sum;
	wire Cout;
	initial begin
		//FS <= 5'b0;
    	//CO <= 1'b0;
			A <= 64'd0;
		B <= 64'd0;
		Cin <= 1'b0;
	//	A <= {$random, $random};
	//	B <= {$random, $random};
	//	Cin <= {$random};
	#1024 $stop; //then stop once all possibilities have been tested (will happen at #320)
	end

	always begin
	#5 A <= A + 1'b1; //every 5 ticks
	//#5	A <= {32'd0, $random};
	//#5	B <= {32'd0, $random};
	//#5	Cin <= {$random};
	end
	/*
	always begin
		#160 CO <= CO + 1'b1; //after it has finished testing all operations with where CO=0, make CO=1 and redo all calculations
	end
	*/
	CLA_64bit dut (Sum, Cout, A, B, Cin); //instantiating ALU module
	


endmodule