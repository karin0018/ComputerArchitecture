`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB
// Engineer: Wu Yuzhang
//
// Design Name: RISCV-Pipline CPU
// Module Name: RV32Core
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Top level of our CPU Core
//////////////////////////////////////////////////////////////////////////////////
//功能说明
    //RV32I 指令集CPU的顶层模�?
//实验要求
    //无需修改

module RV32Core(
    input wire CPU_CLK,
    input wire CPU_RST,
    input wire [31:0] CPU_Debug_DataRAM_A2,
    input wire [31:0] CPU_Debug_DataRAM_WD2,
    input wire [3:0] CPU_Debug_DataRAM_WE2,
    output wire [31:0] CPU_Debug_DataRAM_RD2,
    input wire [31:0] CPU_Debug_InstRAM_A2,
    input wire [31:0] CPU_Debug_InstRAM_WD2,
    input wire [ 3:0] CPU_Debug_InstRAM_WE2,
    output wire [31:0] CPU_Debug_InstRAM_RD2
    );
	//wire values definitions
    wire StallF, FlushF, StallD, FlushD, StallE, FlushE, StallM, FlushM, StallW, FlushW;
    wire [31:0] PC_In;
    wire [31:0] PCF;
    wire [31:0] Instr, PCD;
    wire JalD, JalrD, LoadNpcD, MemToRegD, AluSrc1D;
    wire [2:0] RegWriteD;
    wire [3:0] MemWriteD;
    wire [1:0] RegReadD;
    wire [2:0] BranchTypeD;
    wire [3:0] AluContrlD;
    wire [1:0] AluSrc2D;
    wire [2:0] RegWriteW;
    wire [4:0] RdW;
    wire [31:0] RegWriteData;
    wire [31:0] DM_RD_Ext;
    wire [2:0] ImmType;
    wire [31:0] ImmD;
    wire [31:0] JalNPC;
    wire [31:0] BrNPC;
    wire [31:0] ImmE;
    wire [6:0] OpCodeD, Funct7D;
    wire [2:0] Funct3D;
    wire [4:0] Rs1D, Rs2D, RdD;
    wire [4:0] Rs1E, Rs2E, RdE;
    wire [31:0] RegOut1D;
    wire [31:0] RegOut1E;
    wire [31:0] RegOut2D;
    wire [31:0] RegOut2E;
    wire JalrE;
    wire [2:0] RegWriteE;
    wire MemToRegE;
    wire [3:0] MemWriteE;
    wire LoadNpcE;
    wire [1:0] RegReadE;
    wire [2:0] BranchTypeE;
    wire [3:0] AluContrlE;
    wire AluSrc1E;
    wire [1:0] AluSrc2E;
    wire [31:0] Operand1;
    wire [31:0] Operand2;
    wire BranchE;
    wire [31:0] AluOutE;
    wire [31:0] AluOutM;
    wire [31:0] ForwardData1;
    wire [31:0] ForwardData2;
    wire [31:0] PCE;
    wire [31:0] StoreDataM;
    wire [4:0] RdM;
    wire [31:0] PCM;
    wire [2:0] RegWriteM;
    wire MemToRegM;
    wire [3:0] MemWriteM;
    wire LoadNpcM;
    wire [31:0] DM_RD;
    wire [31:0] ResultM;
    wire [31:0] ResultW;
    wire MemToRegW;
    wire [1:0] Forward1E;
    wire [1:0] Forward2E;
    wire [1:0] LoadedBytesSelect;

     // CSR Instructions
    wire [31:0] CSR_dataD,CSR_dataE,CSR_opdata,CSR_dataW,RegWriteData_csr,AluOutM_csr;
    wire [31:0] CSR_OriginDataM,CSR_OriginDataW;
    wire [11:0] CSR_addrD,CSR_addrE,CSR_addrM,CSR_addrW;
    wire CSR_write_enD,CSR_imm_or_regD,CSR_write_enE,CSR_imm_or_regE,CSR_write_enM,CSR_write_enW;
    wire [31:0] ALU_op1,ALU_op2;
    wire [1:0] CSR_ForwardE; // 旁路控制信号
    wire [31:0] CSR_immD,CSR_immE;

    // ---------- Data cache miss ----------
    wire DCacheMiss;

    //wire values assignments
    assign {Funct7D, Rs2D, Rs1D, Funct3D, RdD, OpCodeD} = Instr;
    assign JalNPC=ImmD+PCD;
    assign ForwardData1 = Forward1E[1]?(AluOutM_csr):( Forward1E[0]?RegWriteData_csr:RegOut1E );
    assign Operand1 = AluSrc1E?PCE:ForwardData1;
    assign ForwardData2 = Forward2E[1]?(AluOutM_csr):( Forward2E[0]?RegWriteData_csr:RegOut2E );
    assign Operand2 = AluSrc2E[1]?(ImmE):( AluSrc2E[0]?Rs2E:ForwardData2 );
    assign ResultM = LoadNpcM ? (PCM+4) : AluOutM;
    assign RegWriteData = ~MemToRegW?ResultW:DM_RD_Ext;

    // CSR assign
    assign RegWriteData_csr = (CSR_write_enW) ? CSR_OriginDataW: RegWriteData;
    assign AluOutM_csr = (CSR_write_enM) ? CSR_OriginDataM: AluOutM;
    assign CSR_immD = {27'b0,Instr[19:15]};
    assign CSR_addrD = Instr[31:20];
    assign ALU_op1 = (CSR_write_enE & CSR_imm_or_regE) ? (CSR_immE):(Operand1); // CSR_imm_or_reg = 1 选择立即数，= 0 选择 寄存�? rs1

    // assign CSR_dataM = AluOutM;
    assign ALU_op2 = (CSR_write_enE) ? (CSR_opdata):(Operand2);
    assign CSR_opdata = CSR_ForwardE[1] ? (CSR_dataE):(CSR_ForwardE[0] ? AluOutM : CSR_dataW); // CSR_data ：CSR 指令�? ALU 的计算参�?


    //Module connections
    // ---------------------------------------------
    // PC-IF
    // ---------------------------------------------
    NPC_Generator NPC_Generator1(
        .PCF(PCF),
        .JalrTarget(AluOutE),
        .BranchTarget(BrNPC),
        .JalTarget(JalNPC),
        .BranchE(BranchE),
        .JalD(JalD),
        .JalrE(JalrE),
        .PC_In(PC_In)
    );

    IFSegReg IFSegReg1(
        .clk(CPU_CLK),
        .en(~StallF),
        .clear(FlushF),
        .PC_In(PC_In),
        .PCF(PCF)
    );

    // ---------------------------------------------
    // ID stage
    // ---------------------------------------------
    IDSegReg IDSegReg1(
        .clk(CPU_CLK),
        .clear(FlushD),
        .en(~StallD),
        .A(PCF),
        .RD(Instr),
        .A2(CPU_Debug_InstRAM_A2),
        .WD2(CPU_Debug_InstRAM_WD2),
        .WE2(CPU_Debug_InstRAM_WE2),
        .RD2(CPU_Debug_InstRAM_RD2),
        .PCF(PCF),
        .PCD(PCD)
    );

    ControlUnit ControlUnit1(
        .Op(OpCodeD),
        .Fn3(Funct3D),
        .Fn7(Funct7D),
        .JalD(JalD),
        .JalrD(JalrD),
        .RegWriteD(RegWriteD),
        .MemToRegD(MemToRegD),
        .MemWriteD(MemWriteD),
        .LoadNpcD(LoadNpcD),
        .RegReadD(RegReadD),
        .BranchTypeD(BranchTypeD),
        .AluContrlD(AluContrlD),
        .AluSrc1D(AluSrc1D),
        .AluSrc2D(AluSrc2D),
        .ImmType(ImmType),
        // CSR signals
        .CSR_write_en(CSR_write_enD),
        .CSR_imm_or_reg(CSR_imm_or_regD)
    );

    ImmOperandUnit ImmOperandUnit1(
        .In(Instr[31:7]),
        .Type(ImmType),
        .Out(ImmD)
    );

    RegisterFile RegisterFile1(
        .clk(CPU_CLK),
        .rst(CPU_RST),
        .WE3(|RegWriteW),
        .A1(Rs1D),
        .A2(Rs2D),
        .A3(RdW),
        .WD3(RegWriteData_csr),
        .RD1(RegOut1D),
        .RD2(RegOut2D)
    );

    // CSR File
    CSRFile CSRFile1(
        .clk(CPU_CLK),
        .rst(CPU_RST),
        .CSR_write_en(CSR_write_enD),
        .CSR_write_addr(CSR_addrW),
        .CSR_read_addr(CSR_addrD),
        .CSR_write_data(CSR_dataW),
        .CSR_read_data(CSR_dataD)
    );

    // ---------------------------------------------
    // EX stage
    // ---------------------------------------------
    EXSegReg EXSegReg1(
        .clk(CPU_CLK),
        .en(~StallE),
        .clear(FlushE),
        .PCD(PCD),
        .PCE(PCE),
        .JalNPC(JalNPC),
        .BrNPC(BrNPC),
        .ImmD(ImmD),
        .ImmE(ImmE),
        .RdD(RdD),
        .RdE(RdE),
        .Rs1D(Rs1D),
        .Rs1E(Rs1E),
        .Rs2D(Rs2D),
        .Rs2E(Rs2E),
        .RegOut1D(RegOut1D),
        .RegOut1E(RegOut1E),
        .RegOut2D(RegOut2D),
        .RegOut2E(RegOut2E),
        .JalrD(JalrD),
        .JalrE(JalrE),
        .RegWriteD(RegWriteD),
        .RegWriteE(RegWriteE),
        .MemToRegD(MemToRegD),
        .MemToRegE(MemToRegE),
        .MemWriteD(MemWriteD),
        .MemWriteE(MemWriteE),
        .LoadNpcD(LoadNpcD),
        .LoadNpcE(LoadNpcE),
        .RegReadD(RegReadD),
        .RegReadE(RegReadE),
        .BranchTypeD(BranchTypeD),
        .BranchTypeE(BranchTypeE),
        .AluContrlD(AluContrlD),
        .AluContrlE(AluContrlE),
        .AluSrc1D(AluSrc1D),
        .AluSrc1E(AluSrc1E),
        .AluSrc2D(AluSrc2D),
        .AluSrc2E(AluSrc2E),
        // csr signal
        .CSR_write_enD(CSR_write_enD),
        .CSR_write_enE(CSR_write_enE),
        .CSR_imm_or_regD(CSR_imm_or_regD),
        .CSR_imm_or_regE(CSR_imm_or_regE),
        .CSR_addrD(CSR_addrD),
        .CSR_addrE(CSR_addrE),
        .CSR_immD(CSR_immD),
        .CSR_immE(CSR_immE),
        .CSR_dataD(CSR_dataD),
        .CSR_dataE(CSR_dataE)
    	);

    ALU ALU1(
        .Operand1(ALU_op1),
        .Operand2(ALU_op2),
        .AluContrl(AluContrlE),
        .AluOut(AluOutE)
    	);

    BranchDecisionMaking BranchDecisionMaking1(
        .BranchTypeE(BranchTypeE),
        .Operand1(Operand1),
        .Operand2(Operand2),
        .BranchE(BranchE)
        );

    // ---------------------------------------------
    // MEM stage
    // ---------------------------------------------
    MEMSegReg MEMSegReg1(
        .clk(CPU_CLK),
        .en(~StallM),
        .clear(FlushM),
        .AluOutE(AluOutE),
        .AluOutM(AluOutM),
        .ForwardData2(ForwardData2),
        .StoreDataM(StoreDataM),
        .RdE(RdE),
        .RdM(RdM),
        .PCE(PCE),
        .PCM(PCM),
        .RegWriteE(RegWriteE),
        .RegWriteM(RegWriteM),
        .MemToRegE(MemToRegE),
        .MemToRegM(MemToRegM),
        .MemWriteE(MemWriteE),
        .MemWriteM(MemWriteM),
        .LoadNpcE(LoadNpcE),
        .LoadNpcM(LoadNpcM),
        // csr signal
        .CSR_write_enE(CSR_write_enE),
        .CSR_write_enM(CSR_write_enM),
        .CSR_addrE(CSR_addrE),
        .CSR_addrM(CSR_addrM),
        .CSR_OriginDataE(CSR_opdata),
        .CSR_OriginDataM(CSR_OriginDataM)
    );

    // ---------------------------------------------
    // WB stage
    // ---------------------------------------------
    WBSegReg WBSegReg1(
        .clk(CPU_CLK),
        .rst(CPU_RST),
        .en(~StallW),
        .clear(FlushW),
        .A(AluOutM),
        .WD(StoreDataM),
        .WE(MemWriteM),
        .RD(DM_RD),
        .LoadedBytesSelect(LoadedBytesSelect),
        .A2(CPU_Debug_DataRAM_A2),
        .WD2(CPU_Debug_DataRAM_WD2),
        .WE2(CPU_Debug_DataRAM_WE2),
        .RD2(CPU_Debug_DataRAM_RD2),
        .ResultM(ResultM),
        .ResultW(ResultW),
        .RdM(RdM),
        .RdW(RdW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .MemToRegM(MemToRegM),
        .MemToRegW(MemToRegW),
        // csr signal
        .CSR_write_enM(CSR_write_enM),
        .CSR_write_enW(CSR_write_enW),
        .CSR_addrM(CSR_addrM),
        .CSR_addrW(CSR_addrW),
        .CSR_dataM(AluOutM),
        .CSR_dataW(CSR_dataW),
        .CSR_OriginDataM(CSR_OriginDataM),
        .CSR_OriginDataW(CSR_OriginDataW),
        .DCacheMiss(DCacheMiss)
    );

    DataExt DataExt1(
        .IN(DM_RD),
        .LoadedBytesSelect(LoadedBytesSelect),
        .RegWriteW(RegWriteW),
        .OUT(DM_RD_Ext)
    );
    // ---------------------------------------------
    // Harzard Unit
    // ---------------------------------------------
    HarzardUnit HarzardUnit1(
        .CpuRst(CPU_RST),
        .BranchE(BranchE),
        .JalrE(JalrE),
        .JalD(JalD),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RegReadE(RegReadE),
        .MemToRegE(MemToRegE),
        .RdE(RdE),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .RdW(RdW),
        .RegWriteW(RegWriteW),
        .ICacheMiss(1'b0),
        .DCacheMiss(DCacheMiss),
        .StallF(StallF),
        .FlushF(FlushF),
        .StallD(StallD),
        .FlushD(FlushD),
        .StallE(StallE),
        .FlushE(FlushE),
        .StallM(StallM),
        .FlushM(FlushM),
        .StallW(StallW),
        .FlushW(FlushW),
        .Forward1E(Forward1E),
        .Forward2E(Forward2E),
        // csr signal
        .CSR_addrE(CSR_addrE),
        .CSR_addrM(CSR_addrM),
        .CSR_addrW(CSR_addrW),
        .CSR_write_enE(CSR_write_enE),
        .CSR_write_enM(CSR_write_enM),
        .CSR_write_enW(CSR_write_enW),
        .CSR_ForwardE(CSR_ForwardE)
    	);

endmodule

