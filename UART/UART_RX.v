// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/14/2022
// 
// Module Name: UART_RX
//      1. A simple implementation of UART Receiver
//      2. Did not develop algorithm to deal with parity bit
//      3. Ignored parity bit
// *****************************************************************************

module UART_RX
#(
    parameter   DATA_WIDTH          = 'd8,              // Transmission Data Width
)
(
    input                           uart_clk,       // 115200Hz Clock Signal  
    input                           rst_n,          // Reset Negative  
    input                           rx_in,          // Date Received
    output  reg [DATA_WIDTH-1:0]    rx_out,         // Data Out
    output  reg                     rx_done         // Data Received and Done
);

    localparam  [1:0]   IDLE        =   2'b01;
    localparam  [1:0]   RECEIVE     =   2'b10;

    reg     [1:0]       current_state;
    reg     [3:0]       bit_counter;

    // current_state behavior
    always @ (posedge uart_clk or negedge rst_n) begin
        if (!rst_n)
            current_state   <=  IDLE;
        else begin
            case (current_state)
                IDLE:
                    begin
                        if (rx_in == 0)
                            current_state   <=  RECEIVE;
                        else
                            current_state   <= IDLE;
                    end
                RECEIVE:
                    begin
                        if (bit_counter < DATA_WIDTH + 2)
                            current_state   <=  RECEIVE;
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
            if (current_state == RECEIVE)
                bit_counter <=  bit_counter + 1'b1;
            else
                bit_counter <=  bit_counter;
        end
    end

    // FSM Combinational Logic Behavior
    always @ (*) begin
        case (current_state)
            IDLE:
                begin
                    rx_out  <=  0;
                    rx_done <=  0;
                end
            RECEIVE:
                begin
                    if (bit_counter == DATA_WIDTH-1) begin
                        rx_done             <=  1;
                        rx_out[bit_counter] <=  rx_in;
                    end
                    else if (bit_counter < DATA_WIDTH) begin
                        rx_out[bit_counter] <=  rx_in;
                        rx_done             <=  0;
                    end
                    else begin
                        rx_out              <=  0;
                        rx_done             <=  0;
                    end
                end
            default:
                begin
                    rx_out              <=  0;
                    rx_done             <=  0;
                end
        endcase
    end

endmodule