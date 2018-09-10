module ALU_testbench (); //written 2/4/18
		//ALU input/outputs: A, B, FS, CO, F, status
	
	reg [63:0] A, B; //2 main inputs for ALU
	wire [63:0]F; //answer output of ALU
	wire C_out; //status signalfrom ALU
	//reg [4:0]FS;	//Ainvert (FS[0]), Binvert (FS[1]), and function selector for ALU (FS[4:2])
		//FS[4:2] funcitons are: 000 AND, 001 OR, 010 ADD, 011 xor, 100 shift left, 101 shift right	
		//note that when FS[4:0] = 11000 and beyond, output should be all zeroes, because it's undefined
	reg C_in; //carry in?
	
	//wire PG, GG;


	initial begin
		C_in <= 1'b0;
    	//CO <= 1'b0;
		//A <= {$random, $random};
		//B <= {$random, $random};
		A <= 64'd196;
		B <= 64'd562;
		//AA <= ($random);
		//BB <= ($random);
		//A = {59'b0, AA};
		//B = {59'b0, BB};
		#320 $stop; //then stop once all possibilities have been tested (will happen at #320)
	end

	always begin
		//#5 FS <= FS + 1'b1; //every 5 ticks
		#5 C_in <= {$random};
		A <= {32'd0, $random};
		B <= {32'd0, $random};
		//A <= $random;
		//B <= $random;
	end
	
	//always begin
	//	#160 CO <= CO + 1'b1; //after it has finished testing all operations with where CO=0, make CO=1 and redo all calculations
//	end
	
	//CLA_64bit dut (F, C_out, A, B, ); //instantiating ALU module
		CLA_64bit dut (F, C_out, A, B, C_in); //instantiating ALU module


endmodule
