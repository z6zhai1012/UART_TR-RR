// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/14/2022
// 
// Module Name: UART_TOP
//      1. A simple implementation of UART
//
// Input Ports:
//      1. clk                      : 50MHz Clock Signal  
//      2. rst_n                    : Reset Negative  
//      3. cmd  [15:0]              : [15]      Read/Write 0/1  
//                                    [14:8]    Address  
//                                    [7:0]     Data  
//      4. uart_valid               : Valid Signal for UART  
//      5. tx                       : UART Transmitter
//
// Output Ports:
//      1. uart_ready               : Ready Signal for UART  
//      2. read_data    [7:0]       : Date Read through UART  
//      3. read_valid               : Valid Signal for read_data  
//      4. rx                       : UART Receiver  
//
// *****************************************************************************

module UART_TOP
#(
    parameter   DATA_WIDTH          = 'd8,              // Transmission Data Width
    parameter   BPS                 = 'd115_200,        // UART Out Frequency bits/s
    parameter   SYS_CLK_FREQ        = 'd50_000_000,     // System Clock Frequency
    parameter   CMD_PKT_LEN         = 'd16              // Command Packet Length
)
(
    input                           clk,            // 50MHz Clock Signal  
    input                           rst_n,          // Reset Negative
    
    input   [CMD_PKT_LEN-1:0]       cmd,            // [15]     : Read/Write 0/1  
                                                    // [14:8]   : Address  
                                                    // [7:0]    : Data  
    input                           uart_valid,     // Valid Signal for UART  
    output                          uart_ready,     // Ready Signal for UART  

    output  [DATA_WIDTH-1:0]        read_data,      // Date Read through UART  
    output                          read_valid,     // Valid Signal for read_data  

    output                          tx,             // UART Transitter  
    input                           rx              // UART Receiver  
);

    wire                            uart_clk;
    wire    [DATA_WIDTH-1:0]        tx_data;
    wire                            tx_en;
    wire                            tx_done;
    wire    [DATA_WIDTH-1:0]        rx_data;
    wire                            rx_done;

    UART_IF 
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .BPS(BPS),
        .SYS_CLK_FREQ(SYS_CLK_FREQ),
        .CMD_PKT_LEN(CMD_PKT_LEN)
    )   UART_IF_inst(
        .clk(clk),
        .uart_clk(uart_clk),
        .rst_n(rst_n),
        .cmd(cmd),
        .uart_valid(uart_valid),
        .uart_ready(uart_ready),
        .tx_data(tx_data),
        .tx_en(tx_en),
        .tx_done(tx_done),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .read_data(read_data),
        .read_valid(read_valid)
    );

    UART_TX
    #(
        .DATA_WIDTH(DATA_WIDTH)
    )   UART_TX_inst(
        .uart_clk(uart_clk),
        .rst_n(rst_n),
        .tx_en(tx_en),
        .tx_in(tx_data),
        .tx_out(tx),
        .tx_done(tx_done)
    );

    UART_RX
    #(
        .DATA_WIDTH(DATA_WIDTH)
    )   UART_RX_inst(
        .uart_clk(uart_clk),
        .rst_n(rst_n),
        .rx_in(rx),
        .rx_out(rx_data),
        .rx_done(rx_done)
    );

endmodule