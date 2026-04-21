`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2026 03:31:09 PM
// Design Name: 
// Module Name: io_module
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


module io_module
#(parameter ADDR_WIDTH=15)
   (

    //input clock 
    input clk,
    input reset,
    
    //coming from the rv32_mem_top
    input [31:2] io_addr,
    output logic [31:0] io_rdata,
    input io_we,
    input [3:0] io_be, 
    input [31:0] io_wdata,
    
    input push_button,
    output [3:0] leds
    );
    
    logic [3:0] led_reg;

    assign leds = led_reg;
    
    
    always_ff @(posedge clk)
    begin
      if (reset)
      begin
        led_reg  <= 4'b0;
        io_rdata <= 32'b0;
      end
      else
      begin
        if (io_we && io_addr[3:2] == 2'b01)
        begin
          if (io_be[0])
            led_reg <= io_wdata[3:0];
        end
    
        case (io_addr[3:2])
          2'b00: io_rdata <= {31'b0, push_button};   // ← 2'b00 instead of 30'h0
          2'b01: io_rdata <= {28'b0, led_reg};        // ← 2'b01 instead of 30'h1
          default: io_rdata <= 32'b0;
        endcase
      end
    end

    
//    reg [31:0] mem [(2**ADDR_WIDTH)-1:0];
    
//    always @(posedge clk)
//    begin 
//      io_rdata <= mem[io_addr];
//    end 
endmodule
