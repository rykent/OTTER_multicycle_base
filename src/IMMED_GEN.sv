`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Ryken Thompson
// 
// Create Date: 10/17/2023 07:22:08 PM
// Design Name: Immediate Generator
// Module Name: IMMED_GEN
// Target Devices: Basys3
// Description: Immediate Generator for OTTER MCU
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IMMED_GEN(
    input [31:0] INSTRUCT,
    output [31:0] U_TYPE,
    output [31:0] I_TYPE,
    output [31:0] S_TYPE,
    output [31:0] J_TYPE,
    output [31:0] B_TYPE
    );
    
    assign U_TYPE = {INSTRUCT[31:12], 12'b0};
    assign I_TYPE = {{21{INSTRUCT[31]}}, INSTRUCT[30:20]};
    assign S_TYPE = {{21{INSTRUCT[31]}}, INSTRUCT[30:25], INSTRUCT[11:7]};
    assign J_TYPE = {{12{INSTRUCT[31]}}, INSTRUCT[19:12], INSTRUCT[20], INSTRUCT[30:21], 1'b0};
    assign B_TYPE = {{20{INSTRUCT[31]}}, INSTRUCT[7], INSTRUCT[30:25], INSTRUCT[11:8], 1'b0};
    
endmodule
