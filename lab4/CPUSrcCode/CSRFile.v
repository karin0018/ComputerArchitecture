`timescale 1ns / 1ps
//功能说明
    // CSR 寄存器
    //上升沿写入，异步读的寄存器堆，0号寄存器值始终为32'b0
    //在接入RV32Core时，输入为~clk，因此本模块时钟输入和其他部件始终相反
    //等价于例化本模块时正常接入时钟clk，同时修改代码为always@(negedge clk or negedge rst)
//实验要求
    //无需修改

module CSRFile(
    input wire clk,
    input wire rst,
    input wire CSR_write_en,
    input wire [11:0] CSR_write_addr,
    input wire [11:0] CSR_read_addr,
    input wire [31:0] CSR_write_data,
    output wire [31:0] CSR_read_data // CSR_dataD
    );
    parameter XLEN = 32,
              CSR_NUM = 2**12;

    reg [XLEN-1:0] RegFile[CSR_NUM-1:0];
    integer i;
    // get write data
    always@(negedge clk or posedge rst)
    begin
        if(rst)
            for(i=0;i<CSR_NUM-1;i=i+1)
                RegFile[i][XLEN-1:0]<=32'b0;
        else if( CSR_write_en==1'b1)
            RegFile[CSR_write_addr] <= CSR_write_data;
    end
    // get read data
    assign CSR_read_data = RegFile[CSR_read_addr];

endmodule