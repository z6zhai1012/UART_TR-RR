// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/14/2022
// 
// Module Name: UART_IF
//      1. A simple implementation of UART Interface
//
// *****************************************************************************

module UART_IF
#(
    parameter   DATA_WIDTH          = 'd8,              // Transmission Data Width
    parameter   BPS                 = 'd115_200,        // UART Out Frequency bits/s
    parameter   SYS_CLK_FREQ        = 'd50_000_000,     // System Clock Frequency
    parameter   CMD_PKT_LEN         = 'd16              // Command Packet Length
)
(
    input                           clk,                // 50 MHz Clock Signal
    output                          uart_clk,           // 115200Hz Clock Signal
    input                           rst_n,              // Reset Negative
    input   [CMD_PKT_LEN - 1:0]     cmd,                // [15]     : Read/Write 0/1  
                                                        // [14:8]   : Address  
                                                        // [7:0]    : Data
    input                           uart_valid,         // Valid Signal for UART  
    output                          uart_ready,         // Ready Signal for UART  

    output  [DATA_WIDTH - 1:0]      tx_data,            // Data to send
    output                          tx_en,              // Enable data to send
    input                           tx_done,            // Data sent and done
);




endmodule