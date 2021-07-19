`timescale 1ns / 1ps

/*
主要两部分功能：
1. 更新 buffer
2. 根据 buffer 中的值预测 IF 段指令是否跳转
*/

module btb(
    input wire clk,
    input wire rst,
    input wire [31:0]PCE, // EX 段指令的地址，用于更�?? btb_mem
    input wire [31:0]BrNPC, // 分支跳转地址
    input wire BranchE, // EX 段产生的实际的分支信�??
    input wire [2:0]BranchTypeE, // Branch 信号的类�??
    input wire [31:0]PCF, // PC
    input wire PredE, // EX 段指令的预测信号，用于判断预测是否正�??
    // add bht
    input wire [1:0]bht_state,
    // output
    output reg PredF, // 当前指令的预测信�??
    output reg [31:0] PredPC // 预测的跳转地�??
);
parameter BTB_LEN = 4;
localparam BTB_SIZE = 1<<BTB_LEN; // btb �?? cache 大小
localparam BTB_NUM = 2**BTB_SIZE;


reg [31:0] btb_mem[BTB_SIZE-1:0]; // btb cache
wire [BTB_LEN:0] read_addr = PCF[BTB_LEN+1:2]; // 预测 PCF，即预测当前 IF 段指令是否跳转
wire [BTB_LEN:0] write_addr = PCE[BTB_LEN+1:2];// 根据 EX 段已经判断出来的分支结果，更新 BTB buffer

// ---------- 统计分支预测的正�?? or 错误次数 ----------
reg [31:0] fail_count;
reg [31:0] pass_count;

always @(posedge clk or rst)
begin
    if(rst)
    begin
        fail_count <= 0;
        pass_count <= 0;
    end
    else if(BranchTypeE != 0) // BrType != 0 说明这是�??条分支指令从 ID 段解码过程即可得�??
    begin
        if(PredE == BranchE)
        begin // 预测成功
            pass_count <= pass_count + 1;
        end
        else
        begin // 预测失败
            fail_count <= fail_count + 1;
        end
    end
end


// ---------- 预测失败 or EX 段有跳转�?? buffer 没有命中时更�?? btb  <==> EX 有跳转（�?? BTB 没有命中）时更新 btb_mem ----------
integer i;
always@(posedge clk or rst)
begin
    if(rst)
    begin
        for(i=0; i<BTB_NUM;i = i+1)
            btb_mem[i] <= 32'b0;
    end
   else if(BranchTypeE!=0)
    begin
        btb_mem[write_addr][31:13] <= PCE[2+BTB_LEN+18:2+BTB_LEN];
        btb_mem[write_addr][12:1] <= BrNPC[11:0];
        btb_mem[write_addr][0] <= BranchE;
    end
end

// ---------- 根据历史信息预测下一条要执行的指令地�?? -----------
always @(*)
begin
    if(btb_mem[read_addr][31:13] == PCF[2+BTB_LEN+18:2+BTB_LEN] && bht_state[1]==1 ) // && btb_mem[read_addr][0]==1 && bht_state[1]==1
    begin
    //�?? PCF �?? btb 中命中，且历史有效位�?? 1，则预测 btb 中存储的跳转地址为当�?? EX 段指令的目标跳转地址
        PredF <= 1; // 预测跳转
        PredPC <={20'b0,btb_mem[read_addr][12:1]}; // 预测的目标地�??
    end
    else
    begin
        PredF <= 0;
        PredPC <= PCF+4;
    end
end

endmodule