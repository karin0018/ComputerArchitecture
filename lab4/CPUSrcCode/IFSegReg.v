`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Wu Yuzhang
//
// Design Name: RISCV-Pipline CPU
// Module Name: IFSegReg
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: PC Register
//////////////////////////////////////////////////////////////////////////////////
//功能说明
    //IDSegReg是IF-ID段寄存器
//实验要求
    //无需修改

module IFSegReg(
    input wire clk,rst,
    input wire en, clear,
    input wire [31:0] PC_In,
    output reg [31:0] PCF
    );
    initial PCF = 0;
    reg [31:0] cycle_num;
    always@(posedge clk or rst)
        if(rst)
            cycle_num <= 32'b0;
        else
        begin
            if(en)
            begin
                if(clear)
                    PCF <= 0;
                else
                    PCF <= PC_In;
            end
            cycle_num <= cycle_num + 1;
        end

endmodule

