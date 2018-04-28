
module DatapathLEGv8(ControlWord, constant, status, instruction, data, address, en_write, en_read, clock, reset, PC, r0, r1, r2, r3, r4, r5, r6, r7, instruction_sel, instruction_user/*, read_address, reg_or_mem*/);
	output [96:0] ControlWord;
	inout [63:0] data;
	input clock, reset;
	output [63:0] constant;
	output [4:0] status;
	output [31:0] instruction;
	output [63:0]address;
	output [15:0] PC;
	output [15:0] r0, r1, r2, r3, r4, r5, r6, r7;
	inout en_write, en_read;	//was output
	input instruction_sel;
	input [31:0] instruction_user;
//	input [4:0]read_address;
//	input reg_or_mem;
	
//	wire [4:0] status;
//	wire [63:0] data;
//	wire [96:0] ControlWord;
//	wire [63:0]address;
	wire EN_B;	
	wire [63:0] PC4;
//	wire [63:0] constant;
	wire [4:0] SA, SB, DA;
	wire [63:0] RegAbus, RegBbus, B;
	wire [4:0] FS;
	wire [63:0] ALU_output, MEM_output;
	wire EN_Mem, EN_ALU;
	wire Bsel;
	wire [3:0] ALU_Status;
	wire [1:0] PS;
	wire EN_PC, SL, WM, WR; 
	wire [63:0] A;
	wire [63:0] constant2;	//dummy vairable since we don't want to get constant from control unit, but from control word
//	wire [31:0] instruction;
	wire NS;
	wire PCsel;
	wire [1:0] PS_user;


//always @(posedge clock or posedge reset) begin
//	if(en_write) begin
		assign {NS, constant, EN_PC, EN_Mem, EN_ALU, PCsel, Bsel, SL, WM, WR, PS, FS, SB, SA, DA, EN_B} = ControlWord; //we have the control word, pull all these things off of it in the correct order
/*	end
	else if (en_read) begin
		assign NS = 1'b0;
		assign constant = 64'b0;
		assign EN_PC = 1'b0;
		assign EN_Mem = ~read_address;
		assign EN_ALU = 1'b0;
		assign PCsel = 1'b0;
		assign Bsel = 5'b0;
		assign SL = 1'b0;
		assign WM = 1'b0;
		assign WR = 1'b0;
		assign PS = 2'b0;
		assign FS = 5'b0;
		assign SB = read_address[4:0];
		assign DA = 5'd31;
		assign EN_B = reg_or_mem;
	end
end*/
		
													    //Removed NS so CW went from 94 bits to 93
	assign RegAbus = PCsel ? constant : A;
	assign RegBbus = Bsel ? constant : B;
														 
	RegFile32x64 regfile(A, B, data, DA, SA, SB, WR, reset, clock);

	ALU_LEGv8 alu (A, RegBbus, FS, FS[1], ALU_output, ALU_Status);

	
	RegisterNbit statusReg (status[4:1], ALU_Status, SL, reset, clock); //SL is part of control work. need to figure out how to get that here
	defparam statusReg.N = 4;
	
	assign status[0] = ALU_Status[0];
	
	//RAM256x64sim data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	//RAM256x64m9k data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	//RAM256x64 data_mem (ALU_output, clock, RegBbus, MemWrite, MEM_output);
	
	//RAM256x64 data_mem (ALU_output, ~clock, RegBbus, MemWrite, MEM_output); 
		//clock is inverted so ALU operations happen before reading values. Gives time for fan-in time
	RAM256x64 data_mem (ALU_output, ~clock, data, WM, MEM_output);

	//defparam data_mem.memory_words = 7000;
	assign data = (EN_PC) ? PC4 : 64'bz;
	assign data = EN_Mem ? MEM_output : 64'bz;
	assign data = EN_ALU ? ALU_output : 64'bz;

	assign data = EN_B ? B : 64'bz;
	
	assign PS_user[0] = ~instruction_sel & PS[0];	//when getting instruction from user, pause PC
	assign PS_user[1] = ~instruction_sel & PS[1];	//"" ""
	
	
	ProgramCounter pc (address, PC4, RegAbus, PS_user, clock, reset);
//	ProgramCounter pc_user (address_user, PC4_user, RegAbus, PS_user, clock, reset)
	
//	assign PC = PC4[15:0];
		
	wire [31:0] instruction_rom;
	
	
	rom_case ROM (instruction_rom, address[17:2]);
	
	assign instruction[31:0] = instruction_sel ? instruction_user[31:0] : instruction_rom[31:0];
	
	assign r6 = data[63:48];
	assign r5 = data[47:32];
	assign r4 = data[31:16];
	assign r3 = data[15:0];
    
	control_unit_setup c1 (instruction, status, reset, clock, ControlWord, constant2);
	
//	GPIO_Peripheral gpio (clock, reset, pins, data, address, read, write);

	
endmodule
