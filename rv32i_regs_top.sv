module rv32i_regs_top(
    input  logic        CLK100,
    output logic [9:0]   LED,
    output logic [2:0]   RGB0,
    output logic [2:0]   RGB1,
    output logic [3:0]   SS_ANODE,
    output logic [7:0]   SS_CATHODE,
    input  logic [11:0]  SW,
    input  logic [3:0]   PB,
    inout  logic [23:0]  GPIO,
    output logic [3:0]   SERVO,
    output logic         PDM_SPEAKER,
    input  logic         PDM_MIC_DATA,
    output logic         PDM_MIC_CLK,
    output logic         ESP32_UART1_TXD,
    input  logic         ESP32_UART1_RXD,
    output logic         IMU_SCLK,
    output logic         IMU_SDI,
    input  logic         IMU_SDO_AG,
    input  logic         IMU_SDO_M,
    output logic         IMU_CS_AG,
    output logic         IMU_CS_M,
    input  logic         IMU_DRDY_M,
    input  logic         IMU_INT1_AG,
    input  logic         IMU_INT_M,
    output logic         IMU_DEN_AG
);

    // tie-offs for unused outputs (optional but recommended)
    assign RGB0            = 3'b000;
    assign RGB1            = 3'b000;
    assign SS_ANODE        = 4'b1111;
    assign SS_CATHODE      = 8'hFF;
    assign SERVO           = 4'b0000;
    assign PDM_SPEAKER     = 1'b0;
    assign PDM_MIC_CLK     = 1'b0;
    assign ESP32_UART1_TXD = 1'b1;
    assign IMU_SCLK        = 1'b0;
    assign IMU_SDI         = 1'b0;
    assign IMU_CS_AG       = 1'b1;
    assign IMU_CS_M        = 1'b1;
    assign IMU_DEN_AG      = 1'b0;

    logic        wb_enable;
    logic [4:0]  wb_reg, rs1_reg, rs2_reg;
    logic [31:0] wb_data;
    logic [31:0] rs1_data, rs2_data;
    
//    logic sig, sig_dly, pe;
    
//    always_ff @(posedge CLK100)
//    begin 
//      sig_dly <= PB[1];      
//    end
    
//    assign pe = sig & ~sig_dly;



    assign wb_data   = 32'd11;                  // static test data
    assign wb_reg    = {1'b0, SW[11:8]};         // 0..15
    assign rs2_reg   = {1'b0, SW[7:4]};
    assign rs1_reg   = {1'b0, SW[3:0]};
    assign wb_enable = PB[1];                   // PB1 pressed => enable=1 (active-low)
    //assign wb_enable = pe;
    // PB0 pressed => reset asserted (invert for active-high reset inside regfile)

    rv32i_regs inst (
        .clk       (CLK100),
        .reset     (PB[0]),
        .rs1_reg   (rs1_reg),
        .rs2_reg   (rs2_reg),
        .wb_enable (wb_enable),
        //.wb_enable(pe),
        .wb_reg    (wb_reg),
        .wb_data   (wb_data),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );

    always_comb begin
        LED[4:0] = rs1_data[4:0];
        LED[9:5] = rs2_data[4:0];
    end

endmodule