// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/7/2022
// 
// Module Name: UART_RR
//      1. A simple implementation of UART receiver
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

module UART_RR
#(
    parameter   width           = 'd8,              // Transmission Data Width
    parameter   BPS             = 'd9_600,          // UART Out Frequency bits/s
    parameter   SYS_CLK_FREQ    = 'd50_000_000      // System Clock Frequency
)
(
    input                       sys_clk,
    input                       sys_reset_n,
    input                       uart_rx_data,
    output  reg [width-1:0]     uart_rx_out,
    output  reg                 uart_rx_done
);

    localparam      CPB     = SYS_CLK_FREQ / BPS;   // System Clock Cycles per Bit
    localparam      BPF     = 10;                   // # Bits per Frame

    reg                         rx_state;           // 1: receiving; 0: no
    reg     [2:0]               data_in_regs;       // Avoid Metastable
    reg     [3:0]               bits_counter;
    reg     [31:0]              cycle_counter;


// ******************************//
// Registers' Behaviors
// ******************************//
    // rx_state behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            rx_state <= 0;
        else if ((data_in_regs[2] == 1)&&(data_in_regs[1] == 0))
            rx_state <= 1;
        else if ((bits_counter == BPF - 1) && (cycle_counter == CPB >> 1) && (data_in_regs[2] == 1))
            rx_state <= 0;
        else
            rx_state <= rx_state;
    end

    // data_in_regs behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            data_in_regs <= 3'b111;                 // The default state is 1s
        else
            data_in_regs[0] <= uart_rx_data;
            data_in_regs[1] <= data_in_regs[0];
            data_in_regs[2] <= data_in_regs[1];
    end

    // bits_counter & cycle_counter behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n) begin
            bits_counter    <= 0;
            cycle_counter   <= 0;
        end
        else begin
            // During Transmission of a Frame
            if (rx_state) begin
                // During Transmission of a Single Bit
                if (cycle_counter < CPB - 1) begin
                    cycle_counter   <= cycle_counter + 1;
                    bits_counter    <= bits_counter;
                end
                // Switch to Next Bit Transmission
                else begin
                    cycle_counter   <= 0;
                    bits_counter    <= bits_counter + 1;
                end
            end
            // Turn Off Transmission
            else begin
                cycle_counter   <= 0;
                bits_counter    <= 0;
            end
        end
    end
// ******************************//
// Registers' Behaviors END
// ******************************//

// ******************************//
// Output Ports' Behaviors
// ******************************//
    // uart_rx_out behavior
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            uart_rx_out <= 0;
        else if (rx_state) begin
            // Pick the middle of transmission for stable data
            if (cycle_counter == CPB >> 1) begin
                case (bits_counter) 
                    4'd1:       uart_rx_out[0]  <= data_in_regs[2];
                    4'd2:       uart_rx_out[1]  <= data_in_regs[2];
                    4'd3:       uart_rx_out[2]  <= data_in_regs[2];
                    4'd4:       uart_rx_out[3]  <= data_in_regs[2];
                    4'd5:       uart_rx_out[4]  <= data_in_regs[2];
                    4'd6:       uart_rx_out[5]  <= data_in_regs[2];
                    4'd7:       uart_rx_out[6]  <= data_in_regs[2];
                    4'd8:       uart_rx_out[7]  <= data_in_regs[2];
                    default:    uart_rx_out <= uart_rx_out;
                endcase
            end
            else
                uart_rx_out <= uart_rx_out;
        end
        else
            uart_rx_out <= 0;
    end

    // uart_rx_done
    always @ (posedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n)
            uart_rx_done <= 0;
        else if ((bits_counter == BPF - 1) && (cycle_counter == CPB >> 1) && (data_in_regs[2] == 1))
            uart_rx_done <= 1;
        else
            uart_rx_done <= 0;
    end
// ******************************//
// Output Ports' Behaviors END
// ******************************//

endmodule