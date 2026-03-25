`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 03:15:45 PM
// Design Name: 
// Module Name: lab5_top
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


module lab5_top(
    
    
    input CLK100,           // 100 MHz clock input
    output [9:0] LED,       // RGB1, RGB0, LED 9..0 placed from left to right
    output [2:0] RGB0,      
    output [2:0] RGB1,
    output [3:0] SS_ANODE,   // Anodes 3..0 placed from left to right
    output [7:0] SS_CATHODE, // Bit order: DP, G, F, E, D, C, B, A
    input [11:0] SW,         // SWs 11..0 placed from left to right
    input [3:0] PB,          // PBs 3..0 placed from left to right
    inout [23:0] GPIO,       // PMODA-C 1P, 1N, ... 3P, 3N order
    output [3:0] SERVO,      // Servo outputs
    output PDM_SPEAKER,      // PDM signals for mic and speaker
    input PDM_MIC_DATA,      
    output PDM_MIC_CLK,
    output ESP32_UART1_TXD,  // WiFi/Bluetooth serial interface 1
    input ESP32_UART1_RXD,
    output IMU_SCLK,         // IMU spi clk
    output IMU_SDI,          // IMU spi data input
    input IMU_SDO_AG,        // IMU spi data output (accel/gyro)
    input IMU_SDO_M,         // IMU spi data output (mag)
    output IMU_CS_AG,        // IMU cs (accel/gyro) 
    output IMU_CS_M,         // IMU cs (mag)
    input IMU_DRDY_M,        // IMU data ready (mag)
    input IMU_INT1_AG,       // IMU interrupt (accel/gyro)
    input IMU_INT_M,         // IMU interrupt (mag)
    output IMU_DEN_AG        // IMU data enable (accel/gyro)

    );
    
    logic reset1;
    logic reset2;
    
    always_ff @(posedge CLK100)
    begin 
      reset1 <= PB[0];
      reset2 <= reset1;
    end
    
    logic [31:0] pc_signal_if_mem;
    logic [31:0] addr_to_mem;
    logic [29:0] from_if_to_mem;
    logic [31:0] from_mem_to_if;
    
    logic [31:0] pc_from_if_to_id;
    logic [31:0] pc_from_id_to_ex;
    logic [31:0] pc_from_ex_to_mem;
    
    logic [31:0] iw_from_if_to_id;
    logic [31:0] iw_from_id_to_ex;
    logic [31:0] iw_from_ex_to_mem;
    
    logic [4:0] reg1_from_id_to_regfile;
    logic [4:0] reg2_from_id_to_regfile;
    logic [31:0] reg1_data_from_regfile_to_id;
    logic [31:0] reg2_data_from_regfile_to_id;
    
    logic [4:0] wb_reg_from_id_to_ex;
    logic wb_enable_from_id_to_ex;
    
    logic [4:0] wb_reg_from_ex_to_mem;
    logic wb_enable_from_ex_to_mem;
    
    logic [4:0] wb_reg_from_mem_to_wb;
    logic wb_enable_from_mem_to_wb;
    
    logic [4:0] wb_reg_from_wb_to_regfile;
    logic wb_enable_from_wb_to_regfile;
    
    logic [31:0] alu_out_from_ex_to_mem;
    logic [31:0] alu_out_from_mem_to_wb;
    logic [31:0] alu_data_from_wb_to_regfile;
    
    logic [31:0] data1_from_id_to_ex;
    logic [31:0] data2_from_id_to_ex;
    
    logic [31:0] pc_out_from_mem_to_wb;
    logic [31:0] iw_out_from_mem_to_wb;
    
    logic ebreak_detected_from_id;
    logic halted;
    
    always_ff @(posedge CLK100)
    begin
        if (reset2)
          halted <= 1'b0;
        else if (ebreak_detected_from_id)
          halted <= 1'b1;
    end
    
    
    sync_dual_port_ram dual_port_ram_inst
    (
      .clk(CLK100),
      .i_addr(from_if_to_mem),
      .i_rdata(from_mem_to_if),
      
      .d_addr(),
      .d_rdata(),
      .d_we(),
      .d_be(),
      .d_wdata()
    );
    
    rv32i_regs rv32i_regs_inst
    (
      .clk(CLK100),
      .reset(reset2),
      .rs1_reg(reg1_from_id_to_regfile),
      .rs2_reg(reg2_from_id_to_regfile),
      .wb_enable(wb_enable_from_wb_to_regfile),
      .wb_reg(wb_reg_from_wb_to_regfile),
      .wb_data(alu_data_from_wb_to_regfile),
      .rs1_data(reg1_data_from_regfile_to_id),
      .rs2_data(reg2_data_from_regfile_to_id)
    );
    
    rv32_if_top rv32_if_top_inst
    (
      .clk(CLK100),
      .reset(reset2),
      .halt(halted),
      .memif_addr(from_if_to_mem),
      .memif_data(from_mem_to_if),
      .pc_out(pc_from_if_to_id),
      .iw_out(iw_from_if_to_id)
    );
    
    rv32_id_top rv32_id_top_inst
    (
      .clk(CLK100),
      .reset(reset2),
      .pc_in(pc_from_if_to_id),
      .iw_in(iw_from_if_to_id),
      .regif_rs1_reg(reg1_from_id_to_regfile),
      .regif_rs2_reg(reg2_from_id_to_regfile),
      .regif_rs1_data(reg1_data_from_regfile_to_id),
      .regif_rs2_data(reg2_data_from_regfile_to_id),
      .pc_out(pc_from_id_to_ex),
      .iw_out(iw_from_id_to_ex),
      .wb_reg_out(wb_reg_from_id_to_ex),
      .wb_enable_out(wb_enable_from_id_to_ex),
      .rs1_data_out(data1_from_id_to_ex),
      .rs2_data_out(data2_from_id_to_ex),
      .ebreak_detected(ebreak_detected_from_id),
      
      .df_ex_enable(),
      .df_ex_reg(),
      .df_ex_data(),
      
      .df_mem_enable(),
      .df_mem_reg(),
      .df_mem_data(),
      
      .df_wb_enable(),
      .df_wb_reg(),
      .df_wb_data()
    );
    
    rv32_ex_top rv32_ex_top_inst
    (
      .clk(CLK100),
      .reset(reset2),
      .pc_in(pc_from_id_to_ex),
      .iw_in(iw_from_id_to_ex),
      .wb_reg_in(wb_reg_from_id_to_ex),
      .wb_enable_in(wb_enable_from_id_to_ex),
      .rs1_data_in(data1_from_id_to_ex),
      .rs2_data_in(data2_from_id_to_ex),
      .alu_out(alu_out_from_ex_to_mem),
      .pc_out(pc_from_ex_to_mem),
      .iw_out(iw_from_ex_to_mem),
      .wb_reg_out(wb_reg_from_ex_to_mem),
      .wb_enable_out(wb_enable_from_ex_to_mem)
      
    );
    
    rv32_mem_top rv32_mem_top_inst
    (
      .clk(CLK100),
      .reset(reset2),
      .pc_in(pc_from_ex_to_mem),
      .iw_in(iw_from_ex_to_mem),
      .alu_in(alu_out_from_ex_to_mem),
      .wb_reg_in(wb_reg_from_ex_to_mem),
      .wb_enable_in(wb_enable_from_ex_to_mem),
      .pc_out(pc_out_from_mem_to_wb),
      .iw_out(iw_out_from_mem_to_wb),
      .alu_out(alu_out_from_mem_to_wb),
      .wb_reg_out(wb_reg_from_mem_to_wb),
      .wb_enable_out(wb_enable_from_mem_to_wb)
    );
    
    
    rv32_wb_top rv32_wb_top_inst 
    (
      .clk(CLK100),
      .reset(reset2),
      .pc_in(pc_out_from_mem_to_wb),
      .iw_in(iw_out_from_mem_to_wb),
      .alu_in(alu_out_from_mem_to_wb),
      .wb_reg_in(wb_reg_from_mem_to_wb),
      .wb_enable_in(wb_enable_from_mem_to_wb),
      .regif_wb_enable(wb_enable_from_wb_to_regfile),
      .regif_wb_reg(wb_reg_from_wb_to_regfile),
      .regif_wb_data(alu_data_from_wb_to_regfile)
    );
    
    ila_0 ila_0_inst (
    .clk(CLK100),

    .probe0 (pc_from_if_to_id),              // [31:0]
    .probe1 (iw_from_if_to_id),              // [31:0]
    .probe2 (iw_from_id_to_ex),              // [31:0]
    .probe3 (iw_from_ex_to_mem),             // [31:0]
    .probe4 (reg1_from_id_to_regfile),       // [4:0]
    .probe5 (reg2_from_id_to_regfile),       // [4:0]
    .probe6 (reg1_data_from_regfile_to_id),  // [31:0]
    .probe7 (reg2_data_from_regfile_to_id),  // [31:0]
    .probe8 (alu_out_from_ex_to_mem),        // [31:0]
    .probe9 (wb_enable_from_wb_to_regfile),  // [0:0]
    .probe10(wb_reg_from_wb_to_regfile),     // [4:0]
    .probe11(alu_data_from_wb_to_regfile),   // [31:0]
    .probe12(ebreak_detected_from_id),       // [0:0]
    .probe13(halted)                         // [0:0]
);
    
endmodule
