`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2026 10:29:16 PM
// Design Name: 
// Module Name: top_level
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


module top_level(

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
  
    
    logic [31:2] i_addr;
    logic [31:0] i_rdata;

    logic [31:2] d_addr;
    logic [31:0] d_rdata;
    logic        d_we;
    logic [3:0]  d_be;
    logic [31:0] d_wdata;

    
    
    reg [5:0] sweep;        // goes 0 to 0x14
    
    logic [25:0] div;
    logic [3:0]  scenario_counter;

    logic [31:0] alu_out;
    logic [31:0] rs2;
    logic [1:0]  width;
    logic        unsigned_check;
    logic        we;
    
    // Step 10 output
    logic [31:0] w_data;

    // Step 11 output
    logic [1:0] hold_count;
    logic [3:0]  w_be;
    
    logic [1:0] width_r;
    logic       unsigned_check_r;
    logic [1:0] addr_offset_r;
    
    
//    always_ff @(posedge CLK100)
//    begin
//        div <= div + 1'b1;
//    end
    
// Scenario counter
    always_ff @(posedge CLK100)
    begin
        if (SW[0])
            scenario_counter <= 4'd1;
        else 
        begin
            if (scenario_counter < 4'd8)
                scenario_counter <= scenario_counter + 1'b1;
            else
                scenario_counter <= 4'd1;
        end
    end
    
//    always_ff @(posedge CLK100)
//    begin
//      width_r          <= width;
//      unsigned_check_r <= unsigned_check;
//      addr_offset_r    <= alu_out[1:0];
//    end


//        always_ff @(posedge CLK100)
//        begin
//            if (SW[0])
//            begin
//                scenario_counter <= 4'd1;
//                hold_count       <= 2'd0;
//            end
//            else
//            begin
//                if (hold_count < 2'd2)
//                begin
//                    hold_count <= hold_count + 1'b1;
//                end
//                else
//                begin
//                    hold_count <= 2'd0;
        
//                    if (scenario_counter < 4'd8)
//                        scenario_counter <= scenario_counter + 1'b1;
//                    else
//                        scenario_counter <= 4'd1;
//                end
//            end
//        end
        


    assign i_addr = {26'd0, scenario_counter};   // word address
    
    // Counter to go over all 8 test cases - SW, SB, SH, LB, LBU, LH, LHU, LW
    always_comb
    begin
    
      alu_out    = 32'd0;
      rs2        = 32'd0;
      width      = 2'd0;
      unsigned_check = 1'b0;
      we         = 1'b0;

      case(scenario_counter)
      //d_addr (comes from ALU), d_wdata (used by write operations), width, sign, we
      
        4'b0001: //store word // 1
        begin
          alu_out   = 32'h00000040;
          rs2       = 32'h11223344;
          width     = 2'd2;   // word
          unsigned_check  = 1'b0;   // don't care for store
          we        = 1'b1;
        end
          
        4'b0010: // store 1 byte // 2
        begin 
          alu_out   = 32'h00000044;
          rs2       = 32'hFFFFFFF8;
          width     = 2'd0;   // byte
          unsigned_check = 1'b0;   // don't care for store
          we        = 1'b1;
        end
        
        4'b0011: // Load byte (signed) // 3
        begin 
        
          alu_out   = 32'h00000044;
          rs2       = 32'h00000000;   // don't care
          width     = 2'd0;           // byte
          unsigned_check  = 1'b0;           // signed
          we        = 1'b0;
          
        end
        
        4'b0100: // Load a byte (unsigned) // 4
        begin 
          alu_out   = 32'h00000044;
          rs2       = 32'h00000000;
          width     = 2'd0;
          unsigned_check = 1'b1;   // unsigned
          we        = 1'b0;
        end
        
        4'b0101: //  store halfword // 5
        begin 
        
          alu_out   = 32'h00000048;
          rs2       = 32'hFFFF8001;
          width     = 2'd1;   // halfword
          unsigned_check  = 1'b0;   // don't care for store
          we        = 1'b1;
        end
        
        4'b0110: // Load halfword (signed) // 6
        begin 
          alu_out   = 32'h00000048;
          rs2       = 32'h00000000;
          width     = 2'd1;   // halfword
          unsigned_check  = 1'b0;   // signed
          we        = 1'b0;
        end
        
        4'b0111: // Load halfword (unsigned)  // 7
        begin 
          alu_out   = 32'h00000048;
          rs2       = 32'h00000000;
          width     = 2'd1;
          unsigned_check  = 1'b1;
          we        = 1'b0;
        end
        
        4'b1000: // Load word (signed)  // 8
        begin
          alu_out   = 32'h00000040;
          rs2       = 32'h00000000;
          width     = 2'd2;   // word
          unsigned_check  = 1'b0;  
          we        = 1'b0;
        end
        
        
      endcase  
    end
    
    // Logic for storing word into memory 
//    always_comb
//    begin
//        w_data = 32'd0;

//        case (width)

//            2'd0: begin
//                // store byte uses rs2[7:0]
//                case (alu_out[1:0])
//                    2'b00: w_data = {24'd0, rs2[7:0]};
//                    2'b01: w_data = {16'd0, rs2[7:0], 8'd0};
//                    2'b10: w_data = {8'd0, rs2[7:0], 16'd0};
//                    2'b11: w_data = {rs2[7:0], 24'd0};
//                    default: w_data = 32'd0;
//                endcase
//            end

//            2'd1: begin
//                // store halfword uses rs2[15:0]
//                if (alu_out[1] == 1'b0)
//                    w_data = {16'd0, rs2[15:0]};
//                else
//                    w_data = {rs2[15:0], 16'd0};
//            end

//            2'd2: begin
//                // store word
//                w_data = rs2;
//            end

//            default: begin
//                w_data = 32'd0;
//            end
//        endcase
//    end

    always_comb
    begin
      w_data = 32'd0;

      case (width)
        2'd0: begin
            w_data = {rs2[7:0]} << (8 * alu_out[1:0]); //24'b0
        end

        2'd1: begin
            w_data = {rs2[15:0]} << (8 * alu_out[1:0]); //16'b0
        end

        2'd2: begin
            w_data = rs2;
        end

        default: begin
            w_data = 32'd0;
        end
      endcase
    end

    // Deciding which byte lanes to write at
//    always_comb
//    begin
//      w_be = 4'b0000;
      
//      case(width)
      
//        2'd0:
//        begin 
//          case(alu_out[1:0])
            
//            2'b00: w_be = 4'b0001;
//            2'b01: w_be = 4'b0010;
//            2'b10: w_be = 4'b0100;
//            2'b11: w_be = 4'b1000;
//          endcase 
//        end 
        
//        2'd1:
//        begin 
//          if (alu_out[1] == 1'b0)
//          begin 
//            w_be = 4'b0011;
//          end
//          else 
//          begin 
//            w_be = 4'b1100;
//          end
//        end
        
//        2'd2:
//        begin 
//          w_be = 4'b1111;
//        end
//      endcase 
//    end 


    always_comb
    begin
      w_be = 4'b0000;

      case (width)
        2'd0: 
        begin
            case (alu_out[1:0])
                2'b00: w_be = 4'b0001;
                2'b01: w_be = 4'b0010;
                2'b10: w_be = 4'b0100;
                2'b11: w_be = 4'b1000;
                default: w_be = 4'b0000;
            endcase
        end

        2'd1: 
        begin
            case (alu_out[1:0])
                2'b00: w_be = 4'b0011;
                2'b10: w_be = 4'b1100;
                default: w_be = 4'b0000;
            endcase
        end

        2'd2: 
        begin
            if (alu_out[1:0] == 2'b00)
                w_be = 4'b1111;
            else
                w_be = 4'b0000;
        end

        default: begin
            w_be = 4'b0000;
        end
      endcase
    end
    
    assign d_addr  = alu_out[31:2];
    assign d_wdata = w_data;
    assign d_be    = w_be;
    assign d_we    = we;

    logic [31:0] load_data;

    // logic for loading word out of the memory and into the register 
    always_comb
    begin 
      load_data = 32'b0;
      
      //case(width)
      case(width)
        2'd0:
        begin 
          //case(alu_out[1:0])
          case(alu_out[1:0])
            
            2'd0:
            begin 
              if (unsigned_check == 1'b0)
              begin 
                load_data = {{24{d_rdata[7]}} ,d_rdata[7:0]};
              end
              else 
              begin 
                load_data = {24'b0, d_rdata[7:0]};
              end
            end
            
            2'd1:
            begin 
              if (unsigned_check == 1'b0)
              begin 
                load_data = {{24{d_rdata[15]}} ,d_rdata[15:8]};
              end 
              else
              begin 
                load_data = {24'b0, d_rdata[15:8]};
              end 
            end
            
            2'd2:
            begin 
              if (unsigned_check == 1'b0)
              begin 
                load_data = {{24{d_rdata[23]}} ,d_rdata[23:16]};
              end 
              else
              begin 
                load_data = {24'b0, d_rdata[23:16]};
              end 
            end
            
            2'd3:
            begin 
              if (unsigned_check == 1'b0)
              begin 
                load_data = {{24{d_rdata[31]}} ,d_rdata[31:24]};
              end 
              else
              begin 
                load_data = {24'b0, d_rdata[31:24]};
              end 
            end
          endcase
        end
        
        2'd1:
        begin 
          if(alu_out[1] == 1'b0)
          begin 
            if (unsigned_check == 1'b0)
            begin 
              load_data = {{16{d_rdata[15]}}, d_rdata[15:0]};
            end 
            else 
            begin 
               load_data = {16'b0, d_rdata[15:0]};
            end
          end
          
          else 
          begin 
            if (unsigned_check == 1'b0)
            begin 
              load_data = {{16{d_rdata[31]}}, d_rdata[31:16]};
            end 
            else 
            begin 
               load_data = {16'b0, d_rdata[31:16]};
            end
          end  
        end
        
        2'd2:
        begin
          load_data = d_rdata;
        end 
        
        default
        begin 
          load_data = 32'b0;
        end
      endcase 
    end
    
//    logic [3:0] scenario_counter_r;

//    always_ff @(posedge CLK100)
//    begin
//      scenario_counter_r <= scenario_counter;
//    end
    
    

    sync_dual_port_ram inst (
      .clk(CLK100),
      .i_addr(i_addr),
      .i_rdata(i_rdata),
      .d_addr(d_addr),
      .d_rdata(d_rdata), //represents load data
      .d_we(d_we),
      .d_be(d_be),
      .d_wdata(d_wdata) //represents store data 
      
    );
    

    ila_2 ila_inst(
	.clk(CLK100), // input wire clk


    .probe0(alu_out),  //32 bits
    .probe1(rs2),      //32 bits
    .probe2(we),       // 1 bit 
    
    .probe3(d_wdata),  //32 bits 
    .probe4(d_be),     // 4 bits 
    .probe5(load_data), //32 bits 
    .probe6(d_rdata),     // 32 bits 
    .probe7(scenario_counter) // 4 bits 
    
////	.probe0(i_addr), // input wire [29:0]  probe0  
////	.probe1(d_addr), // input wire [29:0]  probe1 
////	.probe2(i_rdata), // input wire [31:0]  probe2 
////	.probe3(d_rdata) // input wire [31:0]  probe3
);



endmodule
