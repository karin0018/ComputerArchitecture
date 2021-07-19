`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Wu Yuzhang
//
// Design Name: RISCV-Pipline CPU
// Module Name: ControlUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: RISC-V Instruction Decoder
//////////////////////////////////////////////////////////////////////////////////
//功能和接口说�??
    //ControlUnit       是本CPU的指令译码器，组合�?�辑电路
//输入
    // Op               是指令的操作码部�??
    // Fn3              是指令的func3部分
    // Fn7              是指令的func7部分
//输出
    // JalD==1          表示Jal指令到达ID译码阶段
    // JalrD==1         表示Jalr指令到达ID译码阶段
    // RegWriteD        表示ID阶段的指令对应的寄存器写入模�??
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取的�?�写入寄存器,
    // MemWriteD        �??4bit，为1的部分表示有效，对于data memory�??32bit字按byte进行写入,MemWriteD=0001表示只写入最�??1个byte，和xilinx bram的接口类�??
    // LoadNpcD==1      表示将NextPC输出到ResultM,只有 Jar �?? Jarl 指令�?? 1
    // RegReadD         表示A1和A2对应的寄存器值是否被使用到了，用于forward的处�??
    // BranchTypeD      表示不同的分支类型，�??有类型定义在Parameters.v�??
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v�??
    // AluSrc2D         表示Alu输入�??2的�?�择
    // AluSrc1D         表示Alu输入�??1的�?�择
    // ImmType          表示指令的立即数格式
//实验要求
    //补全模块

//----------已补�??

`include "Parameters.v"
module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] Fn3,
    input wire [6:0] Fn7,
    output wire JalD,
    output wire JalrD,
    output reg [2:0] RegWriteD,
    output wire MemToRegD,
    output reg [3:0] MemWriteD,
    output wire LoadNpcD,
    output reg [1:0] RegReadD,
    output reg [2:0] BranchTypeD,
    output reg [3:0] AluContrlD,
    output wire [1:0] AluSrc2D,
    output wire AluSrc1D,
    output reg [2:0] ImmType,
    // CSR signals
    output reg CSR_write_en,
    output reg CSR_imm_or_reg
    );

    // 请补全此处代�??

    parameter op_RI = 7'b0010011,
              op_R = 7'b0110011,
              op_LUI = 7'b0110111,
              op_AUIPC = 7'b0010111,
              op_Jal = 7'b1101111,
              op_Jalr = 7'b1100111,
              op_B = 7'b1100011,
              op_Load = 7'b0000011,
              op_Store = 7'b0100011,
              op_CSR = 7'b1110011;

    assign JalD = (Op == op_Jal) ? 1:0;
    assign JalrD = (Op == op_Jalr) ? 1:0;
    assign MemToRegD = (Op == op_Load) ? 1:0;
    assign LoadNpcD = (Op == op_Jal || Op == op_Jalr) ? 1:0;
    assign AluSrc2D = (Op == op_R || Op == op_B) ? 2'b00:2'b10;
    assign AluSrc1D = (Op == op_AUIPC|| Op == op_Jal) ? 1:0;

    // AluSrc2D = 2'b10; //imm:Operand2 = AluSrc2E[1]?(ImmE):( AluSrc2E[0]?Rs2E:ForwardData2 );
    // AluSrc1D = 1'b0; // rs1:Operand1 = AluSrc1E?PCE:ForwardData1;

    // RegReadD[1]==1  表示A1对应的寄存器值被使用到了
    // RegReadD[0]==1  表示A2对应的寄存器值被使用到了，用�?? forward 的处�??

    always @(*)
    begin
        case(Op)
            7'b0010011: // SLLI,SRLI,SRAI,ADDI,SLLI,SLTU,XORI,ORI,ANDI
            begin
                CSR_imm_or_reg <= 0;
                CSR_write_en <= 0;
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b10;
                BranchTypeD <= 3'b000;
                ImmType <= `ITYPE;
                case (Fn3)
                    3'b000: AluContrlD <= `ADD; // ADDI
                    3'b001: AluContrlD <= `SLL; // SLLI
                    3'b010: AluContrlD <= `SLT; // SLT
                    3'b011: AluContrlD <= `SLTU; // SLTU
                    3'b100: AluContrlD <= `XOR; // XOR
                    3'b110: AluContrlD <= `OR; // OR
                    3'b111: AluContrlD <= `AND; // AND
                    3'b101: // SRLI, SRAI
                    begin
                        case(Fn7)
                            7'b0000000: AluContrlD <= `SRL; // SRLI
                            7'b0100000: AluContrlD <= `SRA; // SRAI
                            default: AluContrlD <= 4'b1111;
                        endcase
                    end
                endcase
            end

            7'b0110011: // ADD、SUB、SLL、SRL、SRA、SLT、SLTU、XOR、OR、AND
            begin
                CSR_write_en <= 0;
                CSR_imm_or_reg <= 0;
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b11;
                BranchTypeD <= 3'b000;
                ImmType <= `RTYPE;
                case (Fn3)
                    3'b001: AluContrlD <= `SLL; // SLL
                    3'b010: AluContrlD <= `SLT; // SLT
                    3'b011: AluContrlD <= `SLTU; // SLTU
                    3'b100: AluContrlD <= `XOR; // XOR
                    3'b110: AluContrlD <= `OR; // OR
                    3'b111: AluContrlD <= `AND; // AND
                    3'b000: // ADD, SUB
                    begin
                        case(Fn7)
                            7'b0000000: AluContrlD <= `ADD; // ADD
                            7'b0100000: AluContrlD <= `SUB; // SUB
                            default: AluContrlD <= 4'b1111;
                        endcase
                    end
                    3'b101: // SRL, SRA
                    begin
                        case(Fn7)
                            7'b0000000: AluContrlD <= `SRL; // SRLI
                            7'b0100000: AluContrlD <= `SRA; // SRAI
                            default: AluContrlD <= 4'b1111;
                        endcase
                    end
                endcase
            end

            7'b0110111: // LUI
            begin
                CSR_write_en <= 0;
                CSR_imm_or_reg <= 0;
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b00;
                BranchTypeD <= 3'b000;
                AluContrlD <= `LUI;
                ImmType <= `UTYPE;
            end

            7'b0010111: // AUIPC
            begin
                CSR_write_en <= 0;
                CSR_imm_or_reg <= 0;
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b00;
                BranchTypeD <= 3'b000;
                AluContrlD <= `ADD;
                ImmType <= `UTYPE;
            end

            7'b1101111: // Jal
            begin
                CSR_write_en <= 0;
                CSR_imm_or_reg <= 0;
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b00;
                BranchTypeD <= 3'b000;
                AluContrlD <= `ADD;
                ImmType <= `JTYPE;
            end
            7'b1100111: // Jalr 采用 I 类编码
            begin
                CSR_write_en <= 0;
                CSR_imm_or_reg <= 0;
                RegWriteD <= `LW;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b10;
                BranchTypeD <= 3'b000;
                AluContrlD <= `ADD;
                ImmType <= `ITYPE;
            end

            7'b1100011: // BEQ BNE BLT BGE BLTU BGEU
            begin
                CSR_write_en <= 0;
                CSR_imm_or_reg <= 0;
                RegWriteD <= `NOREGWRITE;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b11;
                AluContrlD <= 3'b000;
                ImmType <= `BTYPE;
                case (Fn3)
                    3'b000: BranchTypeD <= `BEQ;
                    3'b001: BranchTypeD <= `BNE;
                    3'b100: BranchTypeD <= `BLT;
                    3'b101: BranchTypeD <= `BGE;
                    3'b110: BranchTypeD <= `BLTU;
                    3'b111: BranchTypeD <= `BGEU;
                    default: BranchTypeD <= `NOBRANCH;
                endcase
            end

            7'b0000011: // LB LH LW LBU LHU
            begin
                CSR_write_en <= 0;
                CSR_imm_or_reg <= 0;
                BranchTypeD <= `NOBRANCH;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b10; // A1 A2 只使�?? A1 寄存器的�??
                AluContrlD <= `ADD;
                ImmType <= `ITYPE;
                case (Fn3)
                    3'b000: RegWriteD <= `LB;
                    3'b001: RegWriteD <= `LH;
                    3'b010: RegWriteD <= `LW;
                    3'b100: RegWriteD <= `LBU;
                    3'b101: RegWriteD <= `LHU;
                    default: RegWriteD <= `NOREGWRITE;
                endcase
            end

            7'b0100011: // SB SH SW
            begin
                CSR_write_en <= 0;
                CSR_imm_or_reg <= 0;
                BranchTypeD <= `NOBRANCH;
                RegWriteD <= `NOREGWRITE;
                RegReadD <= 2'b11; // A1 A2 只使�?? A1 寄存器的�??
                AluContrlD <= `ADD;
                ImmType <= `STYPE;
                case (Fn3)
                    3'b000: MemWriteD <= 4'b0001; // SB
                    3'b001: MemWriteD <= 4'b0011; // SH
                    3'b010: MemWriteD <= 4'b1111; // SW
                    default: MemWriteD <= 4'b0000;
                endcase
            end

            7'b1110011: // CSRRW CSRRC CSRRS CSRRWI CSRRCI CSRRSI
            begin
                CSR_write_en <= 1;
                RegWriteD <= `LW;
                ImmType <= `ITYPE;
                MemWriteD <= 4'b0000;
                BranchTypeD <= `NOBRANCH;
                case (Fn3)
                    `CSRRW:
                    begin
                        AluContrlD <= `CSR_OP1;
                        CSR_imm_or_reg <= 0; // 选择寄存器
                        RegReadD <= 2'b10; // 选择寄存器 A1
                    end
                    `CSRRWI:
                    begin
                        AluContrlD <= `CSR_OP1;
                        CSR_imm_or_reg <= 1; // 选择 csr 立即数
                        RegReadD <= 2'b00;
                    end
                    `CSRRC:
                    begin
                        AluContrlD <= `CSR_CLEAR;
                        CSR_imm_or_reg <= 0; // 选择寄存器
                        RegReadD <= 2'b10; // 选择寄存器 A1
                    end
                    `CSRRCI:
                    begin
                        AluContrlD <= `CSR_CLEAR;
                        CSR_imm_or_reg <= 1; // 选择 csr 立即数
                        RegReadD <= 2'b00;
                    end
                    `CSRRS:
                    begin
                        AluContrlD <= `OR;
                        CSR_imm_or_reg <= 0; // 选择寄存器
                        RegReadD <= 2'b10; // 选择寄存器 A1
                    end
                    `CSRRSI:
                    begin
                        AluContrlD <= `OR;
                        CSR_imm_or_reg <= 1; // 选择 csr 立即数
                        RegReadD <= 2'b00;
                    end
                    default:
                    begin
                        AluContrlD <= 4'd15;
                        CSR_imm_or_reg = 0;
                        RegReadD <= 2'b00;
                    end
                endcase
            end
            default:
            begin
                RegWriteD <= 3'b000;
                MemWriteD <= 4'b0000;
                RegReadD <= 2'b00;
                BranchTypeD <= 3'b000;
                AluContrlD <= 4'b1111;
                ImmType <= 3'b111;
            end
        endcase
    end
endmodule

