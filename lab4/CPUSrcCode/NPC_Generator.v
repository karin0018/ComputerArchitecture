`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Wu Yuzhang
//
// Design Name: RISCV-Pipline CPU
// Module Name: NPC_Generator
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Choose Next PC value
//////////////////////////////////////////////////////////////////////////////////
//功能说明
    //NPC_Generator是用来生成Next PC值的模块，根据不同的跳转信号选择不同的新PC值
//输入
    //PCF              旧的PC值
    //JalrTarget       jalr指令的对应的跳转目标
    //BranchTarget     branch指令的对应的跳转目标
    //JalTarget        jal指令的对应的跳转目标
    //BranchE==1       Ex阶段的Branch指令确定跳转
    //JalD==1          ID阶段的Jal指令确定跳转
    //JalrE==1         Ex阶段的Jalr指令确定跳转
//输出
    //PC_In            NPC的值
//实验要求
    //补全模块

module NPC_Generator(
    input wire [31:0] PCF,PCE,JalrTarget, BranchTarget, JalTarget,
    input wire BranchE,JalD,JalrE,
    // add predict signal
    input wire PredF,PredE,
    input wire [31:0] PredPC,
    // output
    output reg [31:0] PC_In
    );

    // 请补全此处代码

    always@(*)
    begin
        // the ex stage instruction have higher privilege
        if (JalrE == 1) PC_In <= JalrTarget;
        else if (BranchE && !PredE) PC_In <= BranchTarget;
        else if (PredE && !BranchE) PC_In <= PCE+4; // PCE 填充，而非PCF
        else if (JalD == 1) PC_In <= JalTarget;
        else if (PredF == 1) PC_In <=PredPC;
        // pc_new = PCF + 4
        else PC_In <= PCF + 4;
    end

endmodule
