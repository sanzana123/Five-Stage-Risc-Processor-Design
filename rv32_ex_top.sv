`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/06/2026 09:10:05 PM
// Design Name: 
// Module Name: rv32_ex_top
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
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module rv32_ex_top(
    input clk,
    input reset,
    
    input [31:0] pc_in,
    input [31:0] iw_in,
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [4:0] wb_reg_in,
    input wb_enable_in,
    
    output reg [31:0] alu_out,
    output [31:0] pc_out,
    output [31:0] iw_out,
    output [4:0] wb_reg_out,
    output wb_enable_out

    );
    
//    reg pre_reset;
//    reg reset_out;

    logic [6:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;
    logic [31:0] imm_ext;
    logic [4:0] shamt;
    logic [4:0] rd_idx, rs1_idx, rs2_idx;
    wire alu_result;
    
    logic [31:0] immediate_jal;
    
    logic [31:0] jal_imm;
    
    logic [31:0] u_imm;
    
    logic [31:0] s_imm;


    
    
    assign opcode = iw_in[6:0];
    assign rd_idx= iw_in[11:7];
    assign func3 = iw_in[14:12];
    assign rs1_idx = iw_in[19:15];
    assign rs2_idx = iw_in[24:20];
    assign func7 = iw_in[31:25]; 
    //assign imm_idx = iw_in[31:20]; 
    
    assign imm_ext = {{20{iw_in[31]}}, iw_in[31:20]};
    assign shamt = iw_in[24:20]; 
    
    assign jal_imm = {{12{iw_in[31]}}, iw_in[19:12], iw_in[20], iw_in[30:21], 1'b0};

    
    assign u_imm = {iw_in[31:12], 12'b0};
    
    assign s_imm = {{20{iw_in[31]}}, iw_in[31:25], iw_in[11:7]};
    // Metastability for reset 
//    always_ff@(posedge clk)
//    begin 
//      pre_reset <= reset;
//      reset_out <= pre_reset;
//    end 
    
    
    alu inst(
      .clk(clk),
      .reset(reset_out),
      .rs1_data_in(rs1_data_in),
      .rs2_data_in(rs2_data_in),
      .opcode(opcode),
      .func3(func3),
      .func7(func7),
      .immediate(imm_ext),
      .jal_immediate(jal_imm),
      .u_immediate(u_imm),
      .s_immediate(s_imm),
      .shamt(shamt),
     // .rd(rd),
      .alu_out(alu_out),
      .pc_in(pc_in)
    );
    
    
    reg [31:0] pc_out_reg;
    reg [31:0] iw_out_reg;
    reg [4:0]  wb_reg_out_reg;
    reg        wb_enable_out_reg;
    
   
    assign pc_out        = pc_out_reg;
    assign iw_out        = iw_out_reg;
    assign wb_reg_out    = wb_reg_out_reg;
    assign wb_enable_out = wb_enable_out_reg;
    
    
    always_ff @(posedge clk)
    begin
        if (reset_out)
        begin
            pc_out_reg        <= 32'd0;
            iw_out_reg        <= 32'd0;
            wb_reg_out_reg    <= 5'd0;
            wb_enable_out_reg <= 1'b0;
        end
        else
        begin
            pc_out_reg        <= pc_in;
            iw_out_reg        <= iw_in;
            wb_reg_out_reg    <= wb_reg_in;
            wb_enable_out_reg <= wb_enable_in;
        end
    end
    
    
endmodule
