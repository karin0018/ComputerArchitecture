`timescale 1ns / 1ps

module bht(
     input clk,
     input rst,
     input wire [31:0] PCE,
     input wire BranchE,
     input wire [2:0] BranchTypeE,
     input wire[31:0] PCF,
     output reg [1:0] bht_state
    );
    reg [1:0] bht_mem[4095:0];
    wire [11:0] read_addr = PCF[13:2];
    wire [11:0] write_addr = PCE[13:2];
    
   always@(*)
   begin
      if(rst)
          bht_state <= 2'b00;
      else
        bht_state<=bht_mem[read_addr];
   end
          
  integer i;
  always@(posedge clk or rst) 
  begin
     if(rst)
     begin
        for(i=0;i<=4095;i=i+1)
        begin
            bht_mem[i] <= 0;
        end
     end
     else if(BranchTypeE!=0)
       case(bht_mem[write_addr])
        2'b00: begin
             if(BranchE==1)
               bht_mem[write_addr]<=2'b01;
             else
                bht_mem[write_addr]<=2'b00;
            end
        2'b01: begin
             if(BranchE==1)
               bht_mem[write_addr]<=2'b11;
             else
               bht_mem[write_addr]<=2'b00;
            end
        2'b11: begin
              if(BranchE==1)
                bht_mem[write_addr]<=2'b11;
              else
                 bht_mem[write_addr]<=2'b10;
             end
        2'b10: begin
              if(BranchE==1)
                 bht_mem[write_addr]<=2'b11;
              else
                 bht_mem[write_addr]<=2'b00;
            end
        default:begin
              if(BranchE==1)
                   bht_mem[write_addr]<=2'b01;
              else
                   bht_mem[write_addr]<=2'b00;
              end
        endcase
    end
    
     
    
endmodule