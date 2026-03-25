`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2026 10:31:43 PM
// Design Name: 
// Module Name: dual_port_ram
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


module sync_dual_port_ram
#(parameter ADDR_WIDTH=15)
   (

    //input clock 
    input clk,
    
    //instruction port (RO)
    input [31:2] i_addr, // instruction address 
    output reg [31:0] i_rdata, //data - will come from en (32 bits in ILA) 
    
    //Data port (RW)
    input logic [31:2] d_addr, //Address where data will come from 
    output reg [31:0] d_rdata, // Data that we are loading from memory (LOAD) 
    input d_we,            // enable for writing, disable for reading
    input logic [3:0] d_be,      // control which bytes inside the 32 bit gets written 
    input logic [31:0] d_wdata       // Data that we are writing or storing into memory (STORE) 
    );
    
    //Mutltidimensional packed array initialized by bit stream from "ram.hex"
    //(* ram_init_file & "ram.hex") logic [3:0][7:0] ram[(2**ADDR_WIDTH)-1:0];
    reg [31:0] mem [(2**ADDR_WIDTH)-1:0];
    
   // reg [31:0] mem [0:1023];   // 1024 words of 32-bit memory
    
    //reg [31:0] alu_out;
    
    initial begin
        $readmemh("memory.mem", mem);   // this file will be created later
    end
    
    always @(posedge clk)
    begin 
      i_rdata <= mem[i_addr];
      //i_rdata <= mem[i_addr[ADDR_WIDTH-1:0]];
      //d_rdata <= mem[d_addr[11:2]];
      
//      if (d_be == 4'b1111)
//      begin 
//        d_rdata <= mem[d_addr[11:2]];
//      end 
    end 
    
    always @ (posedge clk)
    begin 
      if (d_we)
      begin
        if (d_be[0]) mem[d_addr][7:0] <= d_wdata[7:0];
        if (d_be[1]) mem[d_addr][15:8] <= d_wdata[15:8];
        if (d_be[2]) mem[d_addr][23:16] <= d_wdata[23:16];
        if (d_be[3]) mem[d_addr][31:24] <= d_wdata[31:24];
      end
      d_rdata <= mem[d_addr];
    end

    
    // the initialization file needs to be in here. Use readmeh() to read the initialization file. File name, memory name, 
    
    
endmodule
