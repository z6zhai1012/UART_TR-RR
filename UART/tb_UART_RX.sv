// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/7/2022
// 
// Module Name: tb_UART_RX
//      1. A simple testbench for module UART_RX
//
// *****************************************************************************

`timescale 1ns/1ns

module tb_UART_RX();
    reg             uart_clk;
    reg             rst_n;

    // Inputs
    reg             rx_in;
    reg     [10:0]  rx_in_regs;       

    // Outputs
    wire    [7:0]   rx_out;
    wire            rx_done;
    
    localparam  integer     DATA_WIDTH      = 8;
    localparam  integer     BPS             = 9_600;
    localparam  integer     SYS_CLK_FREQ    = 50_000_000;
    localparam  integer     CYCLES_PER_BIT  = SYS_CLK_FREQ / BPS;
    localparam  integer     HALF_CYCLE      = CYCLES_PER_BIT * 10;

    UART_RX #(
        .DATA_WIDTH(DATA_WIDTH)
    ) UART_RX_inst(
        .uart_clk(uart_clk),
        .rst_n(rst_n),
        .rx_in(rx_in),
        .rx_out(rx_out),
        .rx_done(rx_done)
    );

    always #HALF_CYCLE uart_clk=~uart_clk;    // System Clock Frequency of 50MHz


    initial begin
        uart_clk        <= 1'b0;
        rst_n           <= 1'b0;        
        rx_in           <= 1'b1;            // Default data in
        rx_in_regs      <= 11'b11010101010; // Data Frame

        # (HALF_CYCLE * 2)                    // Wait for a cycle
            rst_n       <= 1'b1;            // Start System
        
        # (HALF_CYCLE * 4)
            for (int i = 0; i < 11; i = i + 1) begin
                @ (posedge uart_clk);
                rx_in   <=  rx_in_regs[i];
            end

        @ (posedge rx_done);
        # 100 $finish;
    end

endmodule