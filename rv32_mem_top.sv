`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 04:51:00 PM
// Design Name: 
// Module Name: rv32_mem_top
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


module rv32_mem_top(

    // synchronus clock and reset 
    input clk, 
    input reset,
    
    // from ex
    input [31:0] pc_in,
    input [31:0] iw_in,
    input [31:0] alu_in,
    input [4:0] wb_reg_in, 
    input  wb_enable_in,
    
    // to wb 
    output reg [31:0] pc_out,
    output reg [31:0] iw_out,
    output reg [31:0] alu_out,
    output reg [4:0] wb_reg_out,
    output reg wb_enable_out,
    
    // memory interface
    output [31:2] memif_addr,
    input [31:0] memif_rdata,
    output logic memif_we,
    output logic [3:0] memif_be,
    output [31:0] memif_wdata,
    
    // io interface
    output [31:2] io_addr,
    input [31:0] io_rdata,
    output logic io_we,
    output logic [3:0] io_be, 
    output [31:0] io_wdata,
    
    input [31:0] rs2_data_in,
    output [31:0] memif_rdata_to_wb,
    output [31:0] io_rdata_from_mem_to_wb,
    input we_store_in_from_ex_to_mem,
    
    output reg [1:0] wb_src_out
    
    );
    
    assign memif_addr = alu_in[31:2];
    assign io_addr = alu_in[31:2];
    
    logic [31:0] store_wdata_packed;

    wire [2:0] funct3;
    always_comb begin
      case (funct3)
        3'b010: begin
          // SW
          store_wdata_packed = rs2_data_in;
        end
    
        3'b001: begin
          // SH
          case (alu_in[1])
            1'b0: store_wdata_packed = {16'b0, rs2_data_in[15:0]};   // lanes [15:0]
            1'b1: store_wdata_packed = {rs2_data_in[15:0], 16'b0};   // lanes [31:16]
          endcase
        end
    
        3'b000: begin
          // SB
          case (alu_in[1:0])
            2'b00: store_wdata_packed = {24'b0, rs2_data_in[7:0]};
            2'b01: store_wdata_packed = {16'b0, rs2_data_in[7:0], 8'b0};
            2'b10: store_wdata_packed = {8'b0, rs2_data_in[7:0], 16'b0};
            2'b11: store_wdata_packed = {rs2_data_in[7:0], 24'b0};
          endcase
        end
    
        default: begin
          store_wdata_packed = rs2_data_in;
        end
      endcase
    end
        
   assign memif_wdata = store_wdata_packed;
   assign io_wdata    = store_wdata_packed;
    
    assign memif_rdata_to_wb = memif_rdata;
    assign io_rdata_from_mem_to_wb = io_rdata;
    
    
    // Write Enables
    always_comb 
    begin
      memif_we = 1'b0;
      io_we    = 1'b0;
      if (we_store_in_from_ex_to_mem)
      begin 
        if (alu_in[31])
        begin 
          io_we = 1'b1;
        end
        else
        begin 
          memif_we = 1'b1;
        end 
      end
    end
    
    
    reg [3:0] be;
    
    assign funct3 = iw_in[14:12];
    
    
    
    // funct3 tells you the width: 000=SB, 001=SH, 010=SW
    always @(*) begin
        case (funct3)
            3'b010: be = 4'b1111;              // SW - all 4 bytes
            3'b001: begin                       // SH - 2 bytes
                case (alu_in[1])
                    1'b0: be = 4'b0011;        // lower halfword
                    1'b1: be = 4'b1100;        // upper halfword
                endcase
            end
            3'b000: begin                       // SB - 1 byte
                case (alu_in[1:0])
                    2'b00: be = 4'b0001;       // byte 0
                    2'b01: be = 4'b0010;       // byte 1
                    2'b10: be = 4'b0100;       // byte 2
                    2'b11: be = 4'b1000;       // byte 3
                endcase
            end
            default: be = 4'b0000;
        endcase
    end
    
    assign memif_be = be;
    assign io_be    = be;  // identical for both as the lab says
    
    logic [1:0] wb_src_next;
    
    always_comb 
    begin
      wb_src_next = 2'b00; // default ALU

      if (iw_in[6:0] == 7'b0000011) 
      begin // load
        if (alu_in[31])
          wb_src_next = 2'b10; // io
        else
          wb_src_next = 2'b01; // memory
      end
    end
    
    always_ff @(posedge clk)
    begin 
      if (reset)
        wb_src_out <= 32'b0;
      else 
        wb_src_out <= wb_src_next;
    end


    always_ff @(posedge clk)
    begin
      if (reset)
      begin
        pc_out <= 32'b0;
        iw_out <= 32'b0;
        alu_out <= 32'b0;
        wb_reg_out <= 5'b0;
        wb_enable_out <= 1'b0; 
      end 
      
      else 
      begin 
        pc_out <= pc_in;
        iw_out <= iw_in;
        alu_out <= alu_in;
        wb_reg_out <= wb_reg_in;
        wb_enable_out <= wb_enable_in;
      end  
    end 
    
    

endmodule
