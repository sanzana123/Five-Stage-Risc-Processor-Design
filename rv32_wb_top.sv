`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 05:16:31 PM
// Design Name: 
// Module Name: rv32_wb_top
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


module rv32_wb_top(

    // system clock and synchronous reset 
    input clk, 
    input reset,
    
    // from mem 
    input [31:0] pc_in,
    input [31:0] iw_in,
    input [31:0] alu_in,
    input [4:0] wb_reg_in,
    input wb_enable_in, 
    
    // register interface 
    output  regif_wb_enable,
    output  [4:0] regif_wb_reg,
    output logic ebreak_detected,
    
    input [31:0] memif_rdata,
    input [31:0] io_rdata,
    
    input [1:0] wb_src_in,
    output logic [31:0] regif_wb_data
    );
    
    always_comb 
    begin
      case (wb_src_in)
        2'b00: regif_wb_data = alu_in;
        2'b01: regif_wb_data = memif_rdata;
        2'b10: regif_wb_data = io_rdata;
        default: regif_wb_data = 32'd0;
      endcase
    end
    
    assign regif_wb_enable = wb_enable_in;
    assign regif_wb_reg    = wb_reg_in;
    //assign regif_wb_data   = alu_in;
    
    always_comb
    begin 
      if (iw_in == 32'h0010_0073)
      begin
        ebreak_detected = 1'b1;
      end 
      else 
      begin 
        ebreak_detected = 1'b0;
      end
    end
    

   // always_ff @(posedge clk)
  //  begin
  //      if (reset)
  //      begin
  //          regif_wb_enable <= 1'b0;
  //          regif_wb_reg    <= 5'd0;
  //          regif_wb_data   <= 32'd0;
  //      end
  //      else
  //      begin
  //          regif_wb_enable <= wb_enable_in;
  //          regif_wb_reg    <= wb_reg_in;
  //          regif_wb_data   <= alu_in;
  //      end
  //  end
        
    
    
endmodule
