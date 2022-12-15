// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/14/2022
// 
// Module Name: UART_TX
//      1. A simple implementation of UART Transmitter
//
// *****************************************************************************

module UART_TX
#(
    parameter   DATA_WIDTH          = 'd8,              // Transmission Data Width
    parameter   BPS                 = 'd115_200,        // UART Out Frequency bits/s
    parameter   SYS_CLK_FREQ        = 'd50_000_000,     // System Clock Frequency
    parameter   CMD_PKT_LEN         = 'd16              // Command Packet Length
)
(
    input                           uart_clk,           // 115200Hz Clock Signal  
    input                           rst_n,              // Reset Negative  
    input                           tx_en,              // Transmission Enable
    input   [DATA_WIDTH-1:0]        tx_in,              // Transmission Data
    output  reg                     tx_out,             // Data Out
    output  reg                     tx_done             // Transmission Done
);

    localparam          CYCLES_PER_BIT  =   SYS_CLK_FREQ / BPS;
    localparam  [1:0]   IDLE            =   2'b01;
    localparam  [1:0]   SEND            =   2'b10;

    reg     [DATA_WIDTH-1:0]        tx_in_reg;
    reg     [1:0]                   current_state;
    reg     [3:0]                   bit_counter;
    reg                             parity_bit;

    // tx_in_reg behavior
    always @ (posedge uart_clk or negedge rst_n) begin
        if (!rst_n)
            tx_in_reg   <=  0;
        else if (tx_en)
            tx_in_reg   <=  tx_in;
        else
            tx_in_reg   <=  tx_in_reg;
    end

    // current_state behavior
    always @ (posedge uart_clk or negedge rst_n) begin
        if (!rst_n)
            current_state   <=  IDLE;
        else begin
            case (current_state)
                IDLE:
                    begin
                        if (tx_en == 1)
                            current_state   <=  SEND;
                        else
                            current_state   <=  IDLE;
                    end
                SEND:
                    begin
                        if ((bit_counter < 11) || (tx_en == 1))
                            current_state   <=  SEND;
                        else
                            current_state   <=  IDLE;
                    end
                default:    current_state   <=  IDLE;
            endcase
        end
    end

    // bit_counter behavior
    always @ (posedge uart_clk or negedge rst_n) begin
        if (!rst_n)
            bit_counter     <=  4'b0;
        else if (bit_counter == 10)
            bit_counter     <=  4'b0;
        else begin
            if (current_state == SEND)
                bit_counter <=  bit_counter + 1'b1;
            else
                bit_counter <=  bit_counter;
        end
    end

    // parity_bit behavior
    always @ (posedge uart_clk or negedge rst_n) begin
        if (!rst_n)
            parity_bit  <=  0;
        else if ((bit_counter == 0)||(bit_counter > 9))
            parity_bit  <=  0;
        else if (bit_counter == 9)
            parity_bit  <=  ~parity_bit;
        else begin
            if (tx_in_reg[bit_counter] == 1)
                parity_bit  <=  ~parity_bit;
            else
                parity_bit  <=  parity_bit;
        end
    end

    // FSM Combinational Logic Behavior
    always @ (*) begin
        case (current_state)
            IDLE:
                begin
                    tx_out  <=  1'b1;
                    tx_done <=  1'b0;
                end
            SEND:
                begin
                    if (bit_counter == 0) begin
                        tx_out  <=  1'b0;
                        tx_done <=  1'b0;
                    end
                    else if (bit_counter == 10) begin
                        tx_out  <=  1'b1;
                        tx_done <=  1'b1;
                    end
                    else if (bit_counter == 9) begin
                        tx_out  <=  parity_bit;
                        tx_done <=  1'b0;
                    end
                    else begin
                        tx_out  <=  tx_in_reg[bit_counter-1];
                        tx_done <=  1'b0;
                    end
                end
            default:
                begin
                    tx_out  <=  1'b1;
                    tx_done <=  1'b0;
                end
        endcase
    end

endmodule