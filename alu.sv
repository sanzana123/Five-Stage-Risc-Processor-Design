`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2026 11:22:35 AM
// Design Name: 
// Module Name: alu
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


module alu(
    
    input clk, 
    input reset, 
    input [31:0]rs1_data_in,
    input [31:0]rs2_data_in,
    input logic [6:0]opcode, 
    input logic [2:0]func3,
    input logic [6:0]func7, 
    input logic [31:0]immediate,
    input logic [31:0]jal_immediate,
    input logic [31:0] u_immediate,
    input logic [31:0] s_immediate,
    input logic [4:0] shamt,
    input logic [31:0] pc_in,
    output logic [31:0]alu_out

    );
    
    logic [31:0] rd;
    
    logic [31:0] alu_out_intermediate;
    
    logic [31:0] jump_target;
    logic jump_taken;

    
    always_comb
    begin
      
      alu_out_intermediate = 32'd0;
      case(opcode)
      
      
////////////////////////////////////////////////////////////// Orange Instructions /////////////////////////////////////
      7'b0110011:         
      begin
        case (func3)
          3'b000:
          begin 
            if (func7 == 7'b0000000)
            begin
               alu_out_intermediate = rs1_data_in + rs2_data_in; //ADD
            end 
            else if (func7 == 7'b0100000)
            begin
              alu_out_intermediate = rs1_data_in - rs2_data_in; //SUB
            end 
          end
          
          3'b111:
          begin 
            if (func7 == 7'b0000000)
            begin 
              alu_out_intermediate = rs1_data_in & rs2_data_in; //AND
            end  
          end
          
          3'b110:
          begin 
            if (func7 == 7'b0000000)
            begin 
              alu_out_intermediate = rs1_data_in | rs2_data_in; //OR
            end
          end
          
          3'b100:
          begin 
            if (func7 == 7'b0000000)
            begin 
             alu_out_intermediate = rs1_data_in ^ rs2_data_in; //XOR
            end 
          end
          
          3'b001:
          begin
            if (func7 == 7'b0000000)
            begin 
                  alu_out_intermediate = rs1_data_in << rs2_data_in[4:0]; //SLL
            end 
          end 
          
          3'b101:
          begin
            if (func7 == 7'b0000000)
            begin 
              alu_out_intermediate = rs1_data_in >> rs2_data_in[4:0]; //SRL
            end
            
            else if (func7 == 7'b0100000)
            begin 
              alu_out_intermediate = $signed(rs1_data_in) >>> rs2_data_in[4:0]; //SRA
            end
          end
          
          3'b010:                               // SLT - signed
          begin 
            if (func7 == 7'b0000000)
            begin 
              if ($signed(rs1_data_in) < ($signed(rs2_data_in)))
              begin 
                alu_out_intermediate = 1'b1;
              end
              else 
              begin 
                alu_out_intermediate = 1'b0;
              end
            end
          end
          
          3'b011:                   //SLTU - usigned
          begin
            if (func7 == 7'b0000000)
            begin 
              if (rs1_data_in < rs2_data_in)
              begin 
                alu_out_intermediate = 1'b1;
              end
              else 
              begin 
                alu_out_intermediate = 1'b0;
              end
            end
          end
        endcase
      end
    
      ////////////////////////////////////////////////  Yellow Instructions /////////////////////////////////
      7'b0010011:       
      begin 
        case (func3)
          3'b000:
          begin 
            alu_out_intermediate = rs1_data_in + immediate; //ADDI
          end 
          
          3'b111:
          begin 
            alu_out_intermediate = rs1_data_in & immediate; //ANDI 
          end
          
          3'b110:
          begin 
            alu_out_intermediate = rs1_data_in | immediate; //ORI
          end
          
          3'b100:
          begin 
            alu_out_intermediate  = rs1_data_in ^ immediate; //XORI
          end
          
          3'b001:
          begin 
            alu_out_intermediate = rs1_data_in << shamt; //SLLI
            //rd = rs1_data_in << rs2_data_in;
          end
          
          3'b101:
          begin
            if (func7 == 7'b0000000)
            begin 
              alu_out_intermediate = rs1_data_in >> shamt; //SRLI
              //rd = rs1_data_in >> rs2_data_in;
            end
            else if (func7 == 7'b0100000)
            begin 
              alu_out_intermediate = $signed(rs1_data_in) >>> shamt; //SRAI
              //rd = rs1_data_in >>> rs2_data_in;
            end
          end 
          
          3'b010:                     //SLTI
          begin 
            if ($signed(rs1_data_in) < $signed(immediate)) 
            begin 
              alu_out_intermediate = 1'b1;
            end
            else 
            begin 
              alu_out_intermediate = 1'b0;
            end
          end
          
          3'b011:                     //SLTIU
          begin 
            if (rs1_data_in < immediate)
            begin 
              alu_out_intermediate = 1'b1;
            end
            else 
            begin
              alu_out_intermediate = 1'b0;
            end
          end 
        endcase 
      end
/////////////////////////////////////////////// Lemon colored Instructions //////////////////////////////////////////////////////////////////
      7'b1101111:     //JAL
      begin 
        alu_out_intermediate = pc_in + 32'd4;
        jump_target = pc_in + $signed(jal_immediate);
        //jump_taken = 1'b1;
      end
      
////////////////////////////////////////////////////////// Blue Instruction ////////////////////////////////////////////////////
      7'b1100111:             //JALR
      begin 
        alu_out_intermediate = pc_in + 32'd4;
        jump_target = (rs1_data_in + $signed(immediate)) & 32'hFFFF_FFFE;
        //jump_taken = 1'b1;
      end
      
////////////////////////////////////////////////////// LUI Instruction /////////////////////////////////////////////////////////
      7'b0110111:
      begin 
        alu_out_intermediate = u_immediate;
      end
     
//////////////////////////////////////////////////// AUIPC instruction //////////////////////////////////////////////////////////
      7'b0010111:
      begin 
        alu_out_intermediate = u_immediate+ pc_in;
      end
     
      7'b0000011:     //All load instructions  
      begin 
        alu_out_intermediate = rs1_data_in + $signed(immediate);
      end 
     
      7'b0100011:     //All store instructions 
      begin 
        alu_out_intermediate = rs1_data_in + $signed(s_immediate);
      end
    
      default:
      begin 
        alu_out_intermediate = 32'b0;
      end    

      endcase
    end
    
    always_ff @(posedge clk)
    begin 
      if (reset)
      begin 
        alu_out <= 32'b0;
      end
      else
      begin 
        alu_out <= alu_out_intermediate; 
      end
    end   
    
endmodule
