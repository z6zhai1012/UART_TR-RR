// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/7/2022
// 
// Module Name: UART_TR
//      1. A simple implementation of UART transmitter
//      2. Each frame is composed of:
//          1 bit of start bit (1'b0),
//          8 bits of data,
//          1 bit of parity (Not implemented in this design)
//          1 bit of stop bit (1'b1)
//      3. Design is based on http://t.csdn.cn/sCjGO

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

module UART_TR
#(
    parameter   width           = 'd8,              // Transmission Data Width
    parameter   BPS             = 'd9_600,          // UART Out Frequency bits/s
    parameter   SYS_CLK_FREQ    = 'd50_000_000      // System Clock Frequency
)
(
    input                   sys_clk,
    input                   sys_reset_n,
    input                   uart_tx_en,
    input   [width-1:0]     uart_tx_data,
    output  reg             uart_tx_out,
    output  reg             uart_tx_done
);

    localparam      CPB     = SYS_CLK_FREQ / BPS;   // System Clock Cycles per Bit
    localparam      BPF     = 10;                   // # Bits per Frame

    reg                     tx_state;               // State information: 1 send, 0 no
    reg     [width-1:0]     uart_tx_data_reg;       // Register input
    reg     [3:0]           bits_counter;           // Count number of bits sent
    reg     [31:0]          cycle_counter;          // Count number of cycles passed

// ******************************//
// Registers' Behaviors
// ******************************//
    // uart_tx_reg behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            uart_tx_data_reg <= 0;
        else if (uart_tx_en)
            uart_tx_data_reg <= uart_tx_data;
        else
            uart_tx_data_reg <= uart_tx_data_reg; 
    end

    // tx_state behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            tx_state <= 1'b0;
        // transmit if enabled
        else if (uart_tx_en)
            tx_state <= 1'b1;
        // stop transmission on last bit's last cycle
        else if ((bits_counter == BPF - 1) && (cycle_counter == CPB - 1))
            tx_state <= 1'b0;
        // maintain transmission during transmission or no enabling signal
        else
            tx_state <= tx_state;
    end

    // bits and cycle counters behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n) begin
            bits_counter    <= 0;
            cycle_counter   <= 0;
        end
        // During Transmission of a Frame
        else if (tx_state) begin
            // During Transmission of a Single Bit
            if (cycle_counter < CPB - 1) begin
                cycle_counter <= cycle_counter + 1;
                bits_counter  <= bits_counter;
            end
            // Switch to Next Bit Transmission
            else begin
                cycle_counter <= 0;
                bits_counter  <= bits_counter + 1;
            end
        end
        // Turn Off Transmission
        else begin
            cycle_counter <= 0;
            bits_counter  <= 0;
        end
    end
// ******************************//
// Registers' Behaviors END
// ******************************//

// ******************************//
// Output Ports' Behaviors
// ******************************//
    // uart_tx_done behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            uart_tx_done <= 1'b0;
        // stop transmission on last bit's last cycle
        else if ((bits_counter == BPF - 1) && (cycle_counter == CPB - 1))
            uart_tx_done <= 1'b1;
        // maintain transmission during transmission or no enabling signal
        else
            uart_tx_done <= 1'b0;
    end

    // uart_tx_out behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            uart_tx_out <= 1'b1;                    // Default value is 1
        // If in transmission, choose data out
        else if (tx_state) begin
            case (bits_counter)
                4'd0:       uart_tx_out <= 1'b0;
                4'd1:       uart_tx_out <= uart_tx_data_reg[0];
                4'd2:       uart_tx_out <= uart_tx_data_reg[1];
                4'd3:       uart_tx_out <= uart_tx_data_reg[2];
                4'd4:       uart_tx_out <= uart_tx_data_reg[3];
                4'd5:       uart_tx_out <= uart_tx_data_reg[4];
                4'd6:       uart_tx_out <= uart_tx_data_reg[5];
                4'd7:       uart_tx_out <= uart_tx_data_reg[6];
                4'd8:       uart_tx_out <= uart_tx_data_reg[7];
                4'd9:       uart_tx_out <= 1'b1;
                default:    uart_tx_out <= 1'b1;
            endcase
        end
        // Default Transmission Value is 1
        else
            uart_tx_out <= 1'b1;
    end
// ******************************//
// Output Ports' Behaviors
// ******************************//

endmodule
