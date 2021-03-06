`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Wu Yuzhang
//
// Design Name: RISCV-Pipline CPU
// Module Name: HarzardUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Deal with harzards in pipline
//////////////////////////////////////////////////////////////////////////////////
//功能说明
    //HarzardUnit用来处理流水线冲突，通过插入气泡，forward以及冲刷流水段解决数据相关和控制相关，组合???辑电路
    //可以???后实现???前期测试CPU正确性时，可以在每两条指令间插入四条空指令，然后直接把本模块输出定为，不forward，不stall，不flush
//输入
    //CpuRst                                    外部信号，用来初始化CPU，当CpuRst==1时CPU全局复位清零（所有段寄存器flush），Cpu_Rst==0时cpu???始执行指???
    //ICacheMiss, DCacheMiss                    为后续实验预留信号，暂时可以无视，用来处理cache miss
    //BranchE, JalrE, JalD                      用来处理控制相关
    //Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW     用来处理数据相关，分别表示源寄存???1号码，源寄存???2号码，目标寄存器号码
    //RegReadE RegReadD[1]==1                   表示A1对应的寄存器值被使用到了，RegReadD[0]==1表示A2对应的寄存器值被使用到了，用于forward的处???
    //RegWriteM, RegWriteW                      用来处理数据相关，RegWrite!=3'b0说明对目标寄存器有写入操???
    //MemToRegE                                 表示Ex段当前指??? 从Data Memory中加载数据到寄存器中
//输出
    //StallF, FlushF, StallD, FlushD, StallE, FlushE, StallM, FlushM, StallW, FlushW    控制五个段寄存器进行stall（维持状态不变）和flush（清零）
    //Forward1E     00 is reg1, 01 is wb stage forwarding, 10 is mem stage forwarding
    //Forward2E     00 is reg2, 01 is wb stage forwarding, 10 is mem stage forwarding
    // assign ForwardData1 = Forward1E[1]?(AluOutM):( Forward1E[0]?RegWriteData:RegOut1E );
    // assign ForwardData2 = Forward2E[1]?(AluOutM):( Forward2E[0]?RegWriteData:RegOut2E );
//实验要求
    //补全模块

//---------- 已补???
module HarzardUnit(
    input wire CpuRst, ICacheMiss, DCacheMiss,
    input wire BranchE, JalrE, JalD,
    input wire [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW,
    input wire [1:0] RegReadE,
    input wire MemToRegE,
    input wire [2:0] RegWriteM, RegWriteW,
    input wire PredE, // add prediction signal
    output reg StallF, FlushF, StallD, FlushD, StallE, FlushE, StallM, FlushM, StallW, FlushW,
    output reg [1:0] Forward1E, Forward2E,
    // csr signal
    input wire [11:0] CSR_addrE,CSR_addrM,CSR_addrW,
    input wire CSR_write_enE,CSR_write_enM,CSR_write_enW,
    output reg [1:0] CSR_ForwardE
    );

    // 请补全此处代???

    // generate Forward1E
    always @(*)
    begin
        if(Rs1E && Rs1E == RdM && RegWriteM != 3'b0 && RegReadE[1] == 1)
        begin
            // mem to ex forwarding
            Forward1E <= 2'b10;
        end
        else if (Rs1E && Rs1E == RdW && RegWriteW != 3'b0 && RegReadE[1] == 1)
        begin
            // wb to ex forwarding
            Forward1E <= 2'b01;
        end
        else
        begin
            // no forwarding
            Forward1E <= 2'b00;
        end
    end

    // generate Forward2E
    always @(*)
    begin
        if(Rs2E && Rs2E == RdM && RegWriteM != 3'b0 && RegReadE[0] == 1)
        begin
            // mem to ex forwarding
            Forward2E <= 2'b10;
        end
        else if (Rs2E && Rs2E == RdW && RegWriteW != 3'b0 && RegReadE[0] == 1)
        begin
            // wb to ex forwarding
            Forward2E <= 2'b01;
        end
        else
        begin
            // no forwarding
            Forward2E <= 2'b00;
        end
    end

    // generate CSR_ForwardE
    always @(*)
    begin
        if( CSR_addrE == CSR_addrM && CSR_write_enE && CSR_write_enM)
        begin
            // mem to ex forwarding
            CSR_ForwardE <= 2'b01;
        end
        else if ( CSR_addrE == CSR_addrW && CSR_write_enE && CSR_write_enW)
        begin
            // wb to ex forwarding
            CSR_ForwardE <= 2'b00;
        end
        else
        begin
            // no forwarding
            CSR_ForwardE <= 2'b10;
        end
    end

    // generate StallF, FlushF, StallD, FlushD, StallE, FlushE
    always @(*)
    begin
        if (CpuRst)
        begin
            StallF <= 0;
            FlushF <= 1;
            StallD <= 0;
            FlushD <= 1;
            StallE <= 0;
            FlushE <= 1;
        end
        else
        begin
            if (MemToRegE && (RdE == Rs1D || RdE == Rs2D))
            begin
                // load + use type data hazard, stall IF, stall ID, flash EX
                StallF <= 1;
                FlushF <= 0;
                StallD <= 1;
                FlushD <= 0;
                StallE <= 0;
                FlushE <= 1;
            end
            else if (DCacheMiss)
            begin
            // data cache miss  停顿???有流水段
                StallF <= 1;
                FlushF <= 0;
                StallD <= 1;
                FlushD <= 0;
                StallE <= 1;
                FlushE <= 0;
            end
            else if (BranchE != PredE ||JalrE == 1)
            begin
                // branch instruction, if the branch prediction is wrong, flush ID,flush EX
                StallF <= 0;
                FlushF <= 0;
                StallD <= 0;
                FlushD <= 1;
                StallE <= 0;
                FlushE <= 1;
            end
            else if (JalD == 1)
            begin
                // jal instruction, flush ID, save EX (the last instruction have higher privelage)
                StallF <= 0;
                FlushF <= 0;
                StallD <= 0;
                FlushD <= 1;
                StallE <= 0;
                FlushE <= 0;
            end
            else
            begin
                // no hazard
                StallF <= 0;
                FlushF <= 0;
                StallD <= 0;
                FlushD <= 0;
                StallE <= 0;
                FlushE <= 0;
            end
        end
    end

    // generate StallM, FlushM, StallW, FlushW
    always @(*)
    begin
        if (CpuRst)
        begin
            StallM <= 0;
            FlushM <= 1;
            StallW <= 0;
            FlushW <= 1;
        end
        else if(DCacheMiss)
        begin
            StallM <= 1;
            FlushM <= 0;
            StallW <= 1; // 流水线全部停???
            FlushW <= 0;
        end
        else
        begin
            StallM <= 0;
            FlushM <= 0;
            StallW <= 0;
            FlushW <= 0;
        end
    end

endmodule

