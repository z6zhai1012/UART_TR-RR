// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/7/2022
// 
// Module Name: tb_UART_TX
//      1. A simple testbench for module UART_TX
//
// *****************************************************************************

`timescale 1ns/1ns

module tb_UART_TX();
    reg             uart_clk;
    reg             rst_n;

    // Inputs
    reg     [7:0]   tx_in;
    reg             tx_en;

    // Outputs
    wire            tx_out;
    wire            tx_done;
    
    localparam  integer     DATA_WIDTH      = 8;
    localparam  integer     BPS             = 9_600;
    localparam  integer     SYS_CLK_FREQ    = 50_000_000;
    localparam  integer     CYCLES_PER_BIT  = SYS_CLK_FREQ / BPS;
    localparam  integer     HALF_CYCLE      = CYCLES_PER_BIT * 10;

    UART_TX #(
        .DATA_WIDTH(DATA_WIDTH)
    ) UART_TX_inst(
        .uart_clk(uart_clk),
        .rst_n(rst_n),
        .tx_in(tx_in),
        .tx_en(tx_en),
        .tx_out(tx_out),
        .tx_done(tx_done)
    );

    always #HALF_CYCLE uart_clk=~uart_clk;  // System Clock Frequency of 50MHz


    initial begin
        uart_clk        <=  1'b0;
        rst_n           <=  1'b0;        
        tx_in           <=  1'b1;           // Default data in
        tx_in           <=  8'b01010101;    // Data Frame

        # (HALF_CYCLE * 2)                  // Wait for a cycle
        rst_n       <=  1'b1;               // Start System
        
        # (HALF_CYCLE * 4)
        tx_en       <=  1'b1;

        # (HALF_CYCLE * 2)
        tx_en       <=  1'b0;

        @ (posedge tx_done);
        # (HALF_CYCLE * 2)
        $finish;
    end

endmodule