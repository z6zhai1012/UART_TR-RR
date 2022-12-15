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