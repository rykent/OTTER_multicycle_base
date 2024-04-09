`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ryken Thompson
// 
// Create Date: 10/30/2023 10:49:26 AM
// Design Name: OTTER MCU
// Module Name: OTTER_MCU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module OTTER_MCU(
    input RST,
    input INTR,
    input CLK,
    input [31:0] IOBUS_IN,
    output IOBUS_WR,
    output [31:0] IOBUS_OUT,
    output [31:0] IOBUS_ADDR
    );
    
    logic [31:0] pc_bus;
    logic [31:0] npc_bus;
    logic [31:0] rs1_bus;
    logic [31:0] rs2_bus;
    logic [31:0] alu_res_bus;
    logic [31:0] instr_bus;
    logic [31:0] itype_bus;
    logic [31:0] utype_bus;
    logic [31:0] stype_bus;
    logic [31:0] jtype_bus;
    logic [31:0] btype_bus;
    
    logic [31:0] csr_RD;
    logic [31:0] MTVEC;
    logic [31:0] MEPC;
    logic [31:0] MSTATUS;
    logic mret_exec;
    logic int_taken;
    logic csr_WE;
    
    logic [31:0] mem_data;
    
    logic [31:0] jalr_baddr;
    logic [31:0] branch_baddr;
    logic [31:0] jal_baddr;
    
    logic bcond_to_cu_eq;
    logic bcond_to_cu_lt;
    logic bcond_to_cu_ltu;
    
    logic [31:0] rfwrmux_to_rf;
    logic [31:0] srcAmux_to_alu;
    logic [31:0] srcBmux_to_alu;
    logic [31:0] pcmux_to_pc;
    
    logic PCWrite;
    logic regWrite;
    logic memWE2;
    logic memRDEN1;
    logic memRDEN2;
    logic reset;
    
    logic [3:0] alu_fun;
    logic [1:0] alu_srcA;
    logic [2:0] alu_srcB;
    logic [2:0] pcSource;
    logic [1:0] rf_wr_sel;
    
    assign npc_bus = pc_bus + 4;
    
    //Muxes
    mux_3bit_sel PC_MUX (.A(npc_bus), .B(jalr_baddr), .C(branch_baddr), .D(jal_baddr), .E(MTVEC), .F(MEPC), .sel(pcSource), .O(pcmux_to_pc));
    mux_3bit_sel ALU_SRCB_MUX (.A(rs2_bus), .B(itype_bus), .C(stype_bus), .D(pc_bus), .E(csr_RD), .F(0), .sel(alu_srcB), .O(srcBmux_to_alu));
    mux_2bit_sel ALU_SRCA_MUX (.A(rs1_bus), .B(utype_bus), .C(~rs1_bus), .D(0), .sel(alu_srcA), .O(srcAmux_to_alu));
    mux_2bit_sel RF_WR_MUX (.A(npc_bus), .B(csr_RD), .C(mem_data), .D(alu_res_bus), .sel(rf_wr_sel), .O(rfwrmux_to_rf));
    
    PC PC0 (.PC_WRITE(PCWrite), .PC_DIN(pcmux_to_pc), .PC_RST(reset), .CLK(CLK), .PC_COUNT(pc_bus));
    Memory MEM0 (.MEM_CLK(CLK), .MEM_RDEN1(memRDEN1), .MEM_RDEN2(memRDEN2), .MEM_WE2(memWE2), .MEM_ADDR1(pc_bus[15:2]), .MEM_ADDR2(alu_res_bus), .MEM_DIN2(rs2_bus), .MEM_SIZE(instr_bus[13:12]), .MEM_SIGN(instr_bus[14]), .IO_IN(IOBUS_IN), .IO_WR(IOBUS_WR), .MEM_DOUT1(instr_bus), .MEM_DOUT2(mem_data));
    RF RF0 (.RF_ADR1(instr_bus[19:15]), .RF_ADR2(instr_bus[24:20]), .RF_WA(instr_bus[11:7]), .RF_WD(rfwrmux_to_rf), .RF_EN(regWrite), .CLK(CLK), .RF_RS1(rs1_bus), .RF_RS2(rs2_bus));
    IMMED_GEN IMMED_GEN0 (.INSTRUCT(instr_bus[31:7]), .U_TYPE(utype_bus), .I_TYPE(itype_bus), .S_TYPE(stype_bus), .J_TYPE(jtype_bus), .B_TYPE(btype_bus));
    BRANCH_ADDR_GEN BADDR_GEN0 (.J_TYPE(jtype_bus), .B_TYPE(btype_bus), .PC(pc_bus), .I_TYPE(itype_bus), .RS1(rs1_bus), .JAL(jal_baddr), .BRANCH(branch_baddr), .JALR(jalr_baddr));
    ALU ALU0 (.srcA(srcAmux_to_alu), .srcB(srcBmux_to_alu), .ALU_FUN(alu_fun), .RESULT(alu_res_bus));
    BRANCH_COND_GEN BCOND_GEN0 (.RS1(rs1_bus), .RS2(rs2_bus), .BR_EQ(bcond_to_cu_eq), .BR_LT(bcond_to_cu_lt), .BR_LTU(bcond_to_cu_ltu));
    CU_DCDR CU_DCDR0 (.int_taken(int_taken), .opcode(instr_bus[6:0]), .funct3(instr_bus[14:12]), .funct7(instr_bus[30]), .br_eq(bcond_to_cu_eq), .br_lt(bcond_to_cu_lt), .br_ltu(bcond_to_cu_ltu), .alu_fun(alu_fun), .alu_srcA(alu_srcA), .alu_srcB(alu_srcB), .pcSource(pcSource), .rf_wr_sel(rf_wr_sel));
    CU_FSM CU_FSM0 (.clk(CLK), .RST(RST), .INTR(INTR & MSTATUS[3]), .opcode(instr_bus[6:0]), .funct3(instr_bus[14:12]), .PCWrite(PCWrite), .regWrite(regWrite), .memWE2(memWE2), .memRDEN1(memRDEN1), .memRDEN2(memRDEN2), .reset(reset), .csr_WE(csr_WE), .int_taken(int_taken), .mret_exec(mret_exec));
    CSR CSR0 (.clk(CLK), .RST(reset), .mret_exec(mret_exec), .INT_TAKEN(int_taken), .ADDR(instr_bus[31:20]), .WR_EN(csr_WE), .PC(pc_bus), .WD(alu_res_bus), .RD(csr_RD), .MSTATUS(MSTATUS), .MEPC(MEPC), .MTVEC(MTVEC));
    
    assign IOBUS_OUT = rs2_bus;
    assign IOBUS_ADDR = alu_res_bus;
    
    
endmodule
