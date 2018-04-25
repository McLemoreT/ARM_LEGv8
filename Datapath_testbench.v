
module Datapath_testbench (); 
			
wire [63:0] R5, R2, R0, R30, R15, R12, R1, R28, R22, R7, R9, R23;
wire [63:0] data;
reg [63:0] constant;
wire [93:0] ControlWord; 
reg clock, reset;

wire [63:0] M16, M8;
wire [63:0] PC4; 
wire [63:0] RegAbus, RegBbus, A, B;
wire [63:0] address;
wire [63:0] ALU_output, MEM_output;
wire [4:0] status;
wire [4:0] DA;
wire [4:0] SA;
wire [4:0] SB;
wire [4:0] FS;
wire [3:0] ALU_Status;
wire [1:0] PS;
wire EN_Mem;
wire EN_ALU;
wire Bsel;
wire EN_PC; 
wire SL, WM, WR;
wire EN_B;
wire PCsel;
wire [63:0]M1;


	initial begin
		
		reset <= 1; 
		clock <= 0; 
		#5000 $stop; //then stop
	end
	
	
//Control word is defined as: {SA, SB, DA, RegWrite, MemWrite, FS, Bsel, EN_Mem, EN_ALU} = ControlWord;
	always begin
		#5 reset <=0;
		#100 clock <= ~clock;
		
	
	end
		
	DatapathLEGv8 dut (clock, reset);	
	//viewing the necessary register locations in Modelsim
	assign R0 = dut.regfile.R00;	
	
	assign R1 = dut.regfile.R01;
	assign R2 = dut.regfile.R02;	
	assign M1 = dut.data_mem.mem[1];
	assign R12 = dut.regfile.R12;
	assign R7 = dut.regfile.R07;		
	assign R9 = dut.regfile.R09;	
	assign R23 = dut.regfile.R23;	
	
	assign PC4 = dut.PC4;
	
/*	assign R3 = dut.regfile.R03;
	assign R4 = dut.regfile.R04;
	assign R5 = dut.regfile.R05;
	assign R6 = dut.regfile.R06;


	assign R15 = dut.regfile.R15;
	assign R22 = dut.regfile.R22;
	assign R28 = dut.regfile.R28;
	assign R30 = dut.regfile.R30;	
	//Made wires for all control signals to test if Datapath and Control Unit were connected correctly. Resulted in zeros, high z, xxx.
	assign data = dut.data;
	assign SA = dut.SA;
	assign SB = dut.SB;
	assign DA = dut.DA;
	assign RegAbus = dut.RegAbus;
	assign  RegBbus = dut.RegBbus;
	assign A = dut.A;
	assign B = dut.B;
	assign status = dut.status;
	assign FS = dut.FS;
	assign ALU_output = dut.ALU_output;
	assign MEM_output = dut.MEM_output;
	assign EN_Mem = dut.EN_Mem;
	assign EN_ALU = dut.EN_ALU;
	assign Bsel = dut.Bsel;
	assign PCsel = dut.PCsel;
	assign ALU_Status = dut.ALU_Status;
	assign PS = dut.PS;
	assign EN_PC = dut.EN_PC;
	assign SL = dut.SL;
	assign WM = dut.WM;
	assign WR = dut.WR;

	//assign constant = dut.constant;
	assign address = dut.address;
	assign EN_B = dut.EN_B;
	assign CU_controlWord = dut.c1.control_word;


	//viewing the necessary memory locations in Modelsim
	assign M8 = dut.data_mem.mem[8];
	assign M16 = dut.data_mem.mem[16];
*/
	

endmodule
