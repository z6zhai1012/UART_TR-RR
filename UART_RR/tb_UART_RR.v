// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/7/2022
// 
// Module Name: tb_UART_RR
//      1. A simple testbench for module UART_RR
//      2. Design is based on http://t.csdn.cn/sCjGO
//
// *****************************************************************************

`timescale 1ns/1ns

module tb_UART_RR();
    reg             sys_clk;
    reg             sys_reset_n;
    wire    [7:0]   uart_rx_out;
    wire            uart_rx_done;

    reg     [7:0]   uart_tx_data;
    reg             uart_tx_en;
    wire            uart_tx_done;
    wire            uart_tx_out;
    
    localparam  integer     WIDTH           = 8;
    localparam  integer     BPS             = 9_600;
    localparam  integer     SYS_CLK_FREQ    = 50_000_000;

    UART_TR #(
        .width(8),
        .BPS(BPS),
        .SYS_CLK_FREQ(SYS_CLK_FREQ)
    ) UART_TR_inst(
        .sys_clk(sys_clk),
        .sys_reset_n(sys_reset_n),
        .uart_tx_en(uart_tx_en),
        .uart_tx_data(uart_tx_data),
        .uart_tx_out(uart_tx_out),
        .uart_tx_done(uart_tx_done)
    );


    UART_RR #(
        .width(8),
        .BPS(BPS),
        .SYS_CLK_FREQ(SYS_CLK_FREQ)
    ) UART_RR_inst(
        .sys_clk(sys_clk),
        .sys_reset_n(sys_reset_n),
        .uart_rx_data(uart_tx_out),
        .uart_rx_out(uart_rx_out),
        .uart_rx_done(uart_rx_done)
    );

    always #10 sys_clk=~sys_clk;    // System Clock Frequency of 50MHz

    initial begin
        sys_clk         <= 1'b0;
        sys_reset_n     <= 1'b0;
        uart_tx_en      <= 1'b0;
        uart_tx_data    <= 8'b0;

        # 80
            sys_reset_n <= 1'b1;    // Start System
        
        # 200
            @ (posedge sys_clk);
            uart_tx_en      <= 1'b1;
            uart_tx_data    <= 8'b01010101;

        # 20
            uart_tx_en      <= 1'b0;

        @ (posedge uart_tx_done);
        uart_tx_en      <= 1'b1;
        uart_tx_data    <= 8'b10101010;
        
        @ (posedge uart_rx_done);
        # 100 $finish;
    end

endmodule