`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 04:25:24 PM
// Design Name: 
// Module Name: rv32_id_top
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


module rv32_id_top(

    // system clock and synchronous reset 
    input clk, 
    input reset,
    
    // from if 
    input [31:0] pc_in,
    input [31:0] iw_in, // instruction word coming from the instruction fetch stage to be decoded
    
    // register interface
    output reg [4:0] regif_rs1_reg, // address of rs1 sent from ID to the register file 
    output reg [4:0] regif_rs2_reg, // address of rs2 sent from ID to the register file 
    input  [31:0] regif_rs1_data, // Data read from rs1 and returned by the register file to decode stage 
    input [31:0] regif_rs2_data,  // Data read from rs2 and returned by the register file to decode stage
    
    // to ex
    output reg [31:0] pc_out,
    output reg [31:0] iw_out,
    output reg [4:0] wb_reg_out,
    output reg wb_enable_out, 
    output reg [31:0] rs1_data_out, 
    output reg [31:0] rs2_data_out,
    
    // halt detection
    output logic ebreak_detected,
    
    
    // data hazard: df from ex
    input df_ex_enable,
    input [4:0] df_ex_reg,
    input reg [31:0] df_ex_data,
    
    // data hazard: df from mem
    input df_mem_enable,
    input [4:0] df_mem_reg,
    input [31:0] df_mem_data,
    
    // data hazard: df from wb
    input df_wb_enable,
    input [4:0] df_wb_reg,
    input [31:0] df_wb_data


    );
    
    logic [4:0] wb_reg_dec;
    logic       wb_enable_dec;
    logic [6:0] opcode;
    
    
    always_comb
    begin
      wb_enable_dec   = 1'b0;
      regif_rs1_reg   = iw_in[19:15];
      regif_rs2_reg   = iw_in[24:20];
      wb_reg_dec      = iw_in[11:7];
      opcode          = iw_in[6:0];
      ebreak_detected = 1'b0;
    
      if (iw_in == 32'h0010_0073)
      begin
        ebreak_detected = 1'b1;
        wb_enable_dec   = 1'b0;
      end
      else
      begin
        case (opcode)
          7'b0110011, // R-type
          7'b0010011, // I-type ALU
          7'b0000011, // Loads
          7'b1101111, // JAL
          7'b1100111, // JALR
          7'b0110111, // LUI
          7'b0010111: wb_enable_dec = 1'b1;
    
          default:    wb_enable_dec = 1'b0;
        endcase
      end
    end 
    
    
    always_ff @(posedge clk)
    begin
        if (reset)
        begin
            pc_out        <= 32'd0;
            iw_out        <= 32'd0;
            wb_reg_out    <= 5'd0;
            wb_enable_out <= 1'b0;
            rs1_data_out  <= 32'd0;
            rs2_data_out  <= 32'd0;
        end
        else
        begin
            pc_out        <= pc_in;
            iw_out        <= iw_in;
            wb_reg_out    <= wb_reg_dec;
            wb_enable_out <= wb_enable_dec;
            //rs1_data_out  <= regif_rs1_data;
            //rs2_data_out  <= regif_rs2_data;
        end
    end
    
    logic [31:0] rs1_data_forwarded;
    logic [31:0] rs2_data_forwarded;

    
      
    always_comb
    begin 
      if (df_ex_enable && (df_ex_reg != 5'd0) && (df_ex_reg == iw_in[19:15]))
      begin
        rs1_data_forwarded = df_ex_data; 
      end 
      else if (df_mem_enable && (df_mem_reg != 5'd0) && (df_mem_reg == iw_in[19:15]))
      begin 
        rs1_data_forwarded = df_mem_data;
      end 
      else if (df_wb_enable && (df_wb_reg != 5'd0) && (df_wb_reg == iw_in[19:15]))
      begin 
        rs1_data_forwarded = df_wb_data;
      end 
      else 
      begin
        rs1_data_forwarded = regif_rs1_data;
      end 
    end
    
    assign rs1_data_out = rs1_data_forwarded;
    
    always_comb
    begin 
      if (df_ex_enable && (df_ex_reg != 5'd0) && (df_ex_reg == iw_in[24:20]))
      begin
        rs2_data_forwarded = df_ex_data; 
      end
      else if (df_mem_enable && (df_mem_reg != 5'd0) && (df_mem_reg == iw_in[24:20]))
      begin
        rs2_data_forwarded = df_mem_data; 
      end 
      else if (df_wb_enable && (df_wb_reg != 5'd0) && (df_wb_reg == iw_in[24:20]))
      begin 
        rs2_data_forwarded = df_wb_data;
      end 
      else 
      begin 
        rs2_data_forwarded = regif_rs2_data;
      end 
    end 
    
    assign rs2_data_out = rs2_data_forwarded;
    
    
endmodule
