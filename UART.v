// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/14/2022
// 
// Module Name: UART
//      1. A simple implementation of UART Interface
//      2. Each command frame is composed of:
//          7 bits of data address,
//          8 bits of data, (Write Only)
//          1 bit of Read/Write Indicator (0:read; 1:write)
//      3. Design is based on https://blog.csdn.net/qq_43244515/article/details/124514416

// Input Ports:
//      1. sys_clk                  : System Clock Provided
//      2. sys_reset_n              : Reset Negative
//      3. uart_tx_en               : Transmission Enable
//      4. uart_tx_data[width-1:0]  : Transmission Data
//
// Output Port:
//      1. uart_tx_out              : Transmission Data Out
//      2. uart_tx_done             : Signaling
//
// *****************************************************************************