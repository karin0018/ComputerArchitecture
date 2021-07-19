`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Wu Yuzhang
//
// Design Name: RISCV-Pipline CPU
// Module Name: ALU
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: ALU unit of RISCV CPU
//////////////////////////////////////////////////////////////////////////////////

//功能和接口说明
	//ALU接受两个操作数，根据AluContrl的不同，进行不同的计算操作，将计算结果输出到AluOut
	//AluContrl的类型定义在Parameters.v中
//推荐格式：
    //case()
    //    `ADD:        AluOut<=Operand1 + Operand2;
    //   	.......
    //    default:    AluOut <= 32'hxxxxxxxx;
    //endcase
//实验要求
    //补全模块

`include "Parameters.v"
module ALU(
    input wire [31:0] Operand1,
    input wire [31:0] Operand2,
    input wire [3:0] AluContrl,
    output reg [31:0] AluOut
    );

    // 请补全此处代码 -- 已补全
    // SLL、SRL、SRA 分别执行逻辑左移、逻辑右移、算术右移，被移位的操作数是寄存器rs1，移位次数是寄存器rs2的低5位
    // SLT和SLTU分别执行符号数和无符号数的比较，如果rs1<rs2，则将1写入rd，否则写入0。
    //
    always@(*)
    begin
      case(AluContrl)
        `ADD: AluOut <= Operand1 + Operand2;
        `SUB: AluOut <= Operand1 + ~Operand2 + 1;
        `XOR: AluOut <= Operand1 ^ Operand2;
        `OR:  AluOut <= Operand1 | Operand2;
        `AND: AluOut <= Operand1 & Operand2;
        `SLL: AluOut <= Operand1 << Operand2[4:0];
        `SRL: AluOut <= Operand1 >> Operand2[4:0];
        `SRA: AluOut <= ($signed(Operand1) >>> Operand2[4:0]);
        `SLT: AluOut <= ($signed (Operand1) < $signed (Operand2) ) ? 32'b1 : 32'b0;
        `SLTU: AluOut <= (Operand1 < Operand2) ? 32'b1 : 32'b0;
        `LUI: AluOut <= Operand2;
        `CSR_CLEAR : AluOut <= ~Operand1 & Operand2; // CSR 清零
        `CSR_OP1 : AluOut <= Operand1; // CSR 选择 Op1 中的值覆盖 csr 寄存器
        default: AluOut <= 32'hxxxxxxxx;
      endcase
    end
endmodule

