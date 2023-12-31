/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB                   // I: Data from port B of regfile
);
    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;

    /* YOUR CODE STARTS HERE */
	 wire [31:0] pc, pc_next, pc_result, sx_immed_N, sx_immed_T, data_result, data_operandB, rstatus;
	 wire [31:0] pc_j;
	 wire is_alu, is_addi, is_sw, is_lw, is_of, isNotEqual, isLessThan, overflow, ne, lt, of;
	 wire is_j, is_bne, is_jal, is_jr, is_blt, is_bex, is_setx,ne1,lt1,of1, ctrl_pc_T, ctrl_pc_N_1;
	 wire [4:0] Opcode, rd, rs, rt, shamt, ALU_op;
	
	 //Instruction Fetch
	 register pc_fetch (pc, pc_next, clock, 1'b1, reset); 
	 assign address_imem = pc[11:0];  
	
	 //Instruction Decode
	 assign Opcode = q_imem[31:27];
	 assign rd = q_imem[26:22];
	 assign rs = q_imem[21:17];
	 assign rt = q_imem[16:12];
	
	 assign is_alu  = ~Opcode[4] & ~Opcode[3] & ~Opcode[2] & ~Opcode[1] & ~Opcode[0]; 
	 assign is_addi = ~Opcode[4] & ~Opcode[3] & Opcode[2]  & ~Opcode[1] & Opcode[0];  
	 assign is_sw   = ~Opcode[4] & ~Opcode[3] & Opcode[2]  & Opcode[1]  & Opcode[0];  
	 assign is_lw   = ~Opcode[4] & Opcode[3]  & ~Opcode[2] & ~Opcode[1] & ~Opcode[0]; 
	 assign is_j    = ~Opcode[4] & ~Opcode[3] & ~Opcode[2] & ~Opcode[1] & Opcode[0];  
	 assign is_bne  = ~Opcode[4] & ~Opcode[3] & ~Opcode[2] & Opcode[1]  & ~Opcode[0]; 
	 assign is_jal  = ~Opcode[4] & ~Opcode[3] & ~Opcode[2] & Opcode[1]  & Opcode[0];	 
	 assign is_jr   = ~Opcode[4] & ~Opcode[3] & Opcode[2]  & ~Opcode[1] & ~Opcode[0]; 
	 assign is_blt  = ~Opcode[4] & ~Opcode[3] & Opcode[2]  & Opcode[1]  & ~Opcode[0]; 
	 assign is_bex  = Opcode[4]  & ~Opcode[3] & Opcode[2]  & Opcode[1]  & ~Opcode[0]; 
	 assign is_setx = Opcode[4]  & ~Opcode[3] & Opcode[2]  & ~Opcode[1] & Opcode[0];	 
	
	 assign ALU_op = is_alu? q_imem[6:2] : 5'd0;   
	 assign shamt  = is_alu? q_imem[11:7] : 5'd0;  
	 
	 assign is_add = is_alu & ~ALU_op[4] & ~ALU_op[3] & ~ALU_op[2] & ~ALU_op[1] & ~ALU_op[0]; 
	 assign is_sub = is_alu & ~ALU_op[4] & ~ALU_op[3] & ~ALU_op[2] & ~ALU_op[1] & ALU_op[0];  
	 
	 //Operand Fetch
	 assign sx_immed_N[31:16] = q_imem[16] ? 16'hFFFF:16'h0000;
	 assign sx_immed_N[15:0] = q_imem[15:0]; 
	 
	 assign sx_immed_T[31:27] = 5'd0;
	 assign sx_immed_T[26:0] = q_imem[26:0]; 


	 // Execute
	 assign data_operandB = (is_addi | is_sw | is_lw)? sx_immed_N: data_readRegB;			
	 alu alu_op (data_readRegA, data_operandB, ALU_op, shamt, data_result, isNotEqual, isLessThan, overflow);
	
	 assign is_of = (is_add | is_addi | is_sub) & overflow; 
	 assign rstatus = is_of? (is_add? 32'd1 : (is_addi? 32'd2 : 32'd3)): 32'd0; 
	
	 // Result Store
	 assign address_dmem = data_result[11:0];	
	 assign data = data_readRegB; 
	 assign wren = is_sw; 
			
	 
	 assign ctrl_writeEnable = is_alu | is_addi | is_lw | is_jal | is_setx; 
	 assign ctrl_readRegA = is_bex? 5'd30 : (is_jr? rd : rs); 
	 assign ctrl_readRegB = is_bex? 5'd0 : (is_bne | is_blt | is_sw ? rd : rt); 
	 assign ctrl_writeReg = is_jal? 5'd31 : (is_of | is_setx? 5'd30 : rd);
	

	 alu alu_pc(pc,32'd1,5'd0,5'd0,pc_result,ne,lt,of);
	 assign data_writeReg = is_jal? pc_result : (is_setx? sx_immed_T : (is_of? rstatus : (is_lw? q_dmem : data_result)));
	
	 //Next Instruction
	 alu alu_j(pc_result,sx_immed_N,5'd0,5'd0,pc_j,ne1,lt1,of1);
	 assign ctrl_pc_T = is_j | is_jal | (is_bex & isNotEqual); 
	 assign ctrl_pc_N_1 = (is_bne & isNotEqual)| (is_blt & ~isLessThan & isNotEqual); 
	 assign pc_next = is_jr? data_readRegA : (ctrl_pc_T? sx_immed_T : (ctrl_pc_N_1? pc_j : pc_result));

endmodule
