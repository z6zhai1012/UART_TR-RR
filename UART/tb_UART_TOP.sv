// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/7/2022
// 
// Module Name: tb_UART_IF
//      1. A simple testbench for module UART_TOP
//
// *****************************************************************************

`timescale 1ns/1ns

module tb_UART_TOP();
    localparam  integer     DATA_WIDTH      = 8;
    localparam  integer     BPS             = 9_600;
    localparam  integer     SYS_CLK_FREQ    = 50_000_000;
    localparam  integer     CYCLES_PER_BIT  = SYS_CLK_FREQ / BPS;
    localparam  integer     HALF_CYCLE      = 10;
    localparam  integer     CMD_PKT_LEN     = 16;

    reg                             clk;
    reg                             rst_n;


    reg     [CMD_PKT_LEN - 1:0]     cmd;
    reg                             uart_valid;
    wire                            uart_ready;

    wire    [DATA_WIDTH-1:0]        read_data;
    wire                            read_valid;
    
    wire                            tx;
    reg                             rx;
    


    UART_TOP #(
        .DATA_WIDTH(DATA_WIDTH),
        .BPS(BPS),
        .SYS_CLK_FREQ(SYS_CLK_FREQ),
        .CMD_PKT_LEN(CMD_PKT_LEN)
    ) UART_TOP_inst(
        .clk(clk),
        .rst_n(rst_n),
        .cmd(cmd),
        .uart_valid(uart_valid),
        .uart_ready(uart_ready),
        .read_data(read_data),
        .read_valid(read_valid),
        .tx(tx),
        .rx(rx)
    );

    always #HALF_CYCLE clk  = ~clk;  // System Clock Frequency of 50MHz


    initial begin
        clk             <=  1'b0;
        rst_n           <=  1'b0;        
        uart_valid      <=  1'b0;                   // Default data in
        cmd             <=  16'b1010101001010101;   // Data Frame
        rx              <=  1'b1;

        # (HALF_CYCLE * 2)                  // Wait for a cycle
        rst_n       <=  1'b1;               // Start System
        
        # (HALF_CYCLE * 4)
        uart_valid      <=  1'b1;

        # (HALF_CYCLE * 2)
        uart_valid      <=  1'b0;

        @ (posedge uart_ready)
        $finish;
    end

endmodule