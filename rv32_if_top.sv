`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 04:21:22 PM
// Design Name: 
// Module Name: rv32_if_top
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


module rv32_if_top(

    // System clock and synchronus reset 
    input clk,
    input reset,
    
    //memory interface 
    output [31:2] memif_addr, // address that will be sent to instruction memory 
    input [31:0] memif_data, // instruction word returned from instruction memory 
    input logic halt,
    
    // to id 
    output reg [31:0] pc_out, // output of this stage 
    output [31:0] iw_out // instruction word output passed to the decode stage 
    
    );
    
    parameter logic [31:0] PC_RESET = 32'd0;
    localparam logic [31:0] NOP = 32'h00000013;   // addi x0, x0, 0

    
    logic [31:0] pc_reg;
    logic [31:0] pc_delayed;
    
    always_ff @(posedge clk)
    begin
        if (reset)
            pc_delayed <= PC_RESET;
        else if (halt)
            pc_delayed <= pc_delayed;
        else
            pc_delayed <= pc_reg;
    end
    
    always_ff @(posedge clk) 
    begin 
      if (reset) 
      begin 
        pc_reg <= PC_RESET;
      end 
      else if (halt)
      begin 
        pc_reg <= pc_reg;
      end 
      else
      begin 
        pc_reg <= pc_reg + 32'd4;
      end
    end 
    
   
    assign memif_addr = pc_reg [31:2];


    assign iw_out = memif_data;
    
    always_ff @(posedge clk)
    begin
        if (reset)
            pc_out <= PC_RESET;
        else if (halt)
            pc_out <= pc_out;
        else
            pc_out <= pc_delayed;  
    end
        

    
    
    
endmodule
