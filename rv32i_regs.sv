`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2026 02:16:09 PM
// Design Name: 
// Module Name: rv32i_regs
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


module rv32i_regs(

    // system clock and synchronous reset
    input logic clk, //CLK100
    input logic reset,//PB[0]
    // inputs 
    input logic [4:0] rs1_reg,
    input logic [4:0] rs2_reg,
    input logic wb_enable,
    input logic [4:0] wb_reg,
    input logic [31:0] wb_data,
    // outputs
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data

    );
    
    logic preset;
    logic new_reset;
    
    logic [31:0] regs [31:0];
    integer i;
    
    // Handling metastability of PB[0]
    always_ff @(posedge clk)
    begin 
      preset <= reset;
      new_reset <= preset;
    end
    
    always_ff @(posedge clk)
    begin 
      if (new_reset)
      begin 
        for (i=0; i<6'd32; i++)
        begin 
          regs[i] <= 32'b0;
        end 
      end 
      
      else if ((wb_enable) && (wb_reg != 5'b0))
      begin 
        regs[wb_reg] <= wb_data;
      end 
      
      
    end 
    
    always_comb 
    begin 
       rs1_data = (rs1_reg == 5'd0) ? 32'd0 : regs[rs1_reg];
       rs2_data = (rs2_reg == 5'd0) ? 32'd0 : regs[rs2_reg];
    end
endmodule
