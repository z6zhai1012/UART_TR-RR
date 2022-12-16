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
    output  reg                     uart_clk,           // 115200Hz Clock Signal
    input                           rst_n,              // Reset Negative
    
    input   [CMD_PKT_LEN - 1:0]     cmd,                // [15]     : Read/Write 0/1  
                                                        // [14:8]   : Address  
                                                        // [7:0]    : Data
    input                           uart_valid,         // Valid Signal for UART  
    output  reg                     uart_ready,         // Ready Signal for UART  

    output  reg [DATA_WIDTH - 1:0]  tx_data,            // Data to send
    output  reg                     tx_en,              // Enable data to send
    input                           tx_done,            // Data sent and done

    input   [DATA_WIDTH - 1:0]      rx_data,            // Data Received
    input                           rx_done,            // Data Received Done
    output  reg [DATA_WIDTH - 1:0]  read_data,          // Data Read
    output  reg                     read_valid          // Data Read Valid
);

    localparam          CYCLES_PER_BIT  =   SYS_CLK_FREQ / BPS;
    localparam  [2:0]   IDLE            =   3'b001;
    localparam  [2:0]   SEND            =   3'b010;
    localparam  [2:0]   WAIT            =   3'b100;

    // Receive Data and Send Out Immediately
    always @ (posedge rx_done or negedge rst_n) begin
        if (rx_done) begin
            read_data   <=  rx_data;
            read_valid  <=  1'b1;
        end
        else begin
            read_data   <=  0;
            read_valid  <=  0;
        end
    end

    reg     [2:0]       current_state;
    reg     [31:0]      cycle_counter;
    reg                 send_next;

    // UART_CLK Generation and Cycle Counter
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_clk        <=  0;
            cycle_counter   <=  32'b0;
        end
        else if (cycle_counter == CYCLES_PER_BIT - 1) begin
            uart_clk        <=  ~uart_clk;
            cycle_counter   <=  32'b0;
        end
        else begin
            uart_clk        <=  uart_clk;
            cycle_counter   <=  cycle_counter + 1'b1;
        end
    end

    // Current State and SEND NEXT behavior
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state   <=  0;
            send_next       <=  0;
        end
        else begin
            case (current_state)
                IDLE:
                    begin
                        send_next   <=  0;
                        if (uart_valid == 1)
                            current_state   <=  SEND;
                        else
                            current_state   <=  IDLE;
                    end
                SEND:
                    begin
                        if (send_next == 1)
                            send_next   <=  0;
                        else
                            send_next   <=  cmd[DATA_WIDTH-1];
                        current_state   <= WAIT;
                    end
                WAIT:
                    begin
                        if (send_next == 1 && tx_done == 1)
                            current_state   <=  SEND;
                        else if (send_next == 0 && tx_done == 1)
                            current_state   <=  IDLE;
                        else
                            current_state   <=  WAIT;
                    end
                default:
                    begin
                        current_state   <=  IDLE;
                        send_next       <=  0;
                    end
            endcase
        end
    end
    
    // FSM Combinational Logic Behavior
    always @ (*) begin
        case (current_state)
            IDLE:
                begin
                    uart_ready  <=  1;
                    tx_en       <=  0;
                    tx_data     <=  8'b0;
                end
            SEND:
                begin
                    uart_ready  <=  0;
                    tx_en       <=  1;
                    if (send_next == 1) begin
                        tx_data <=  cmd[DATA_WIDTH-1:0];
                    end
                    else begin
                        tx_data <=  cmd[CMD_PKT_LEN-1:DATA_WIDTH];
                    end
                end
            WAIT:
                begin
                    uart_ready  <=  0;
                    tx_en       <=  0;
                end
            default:
                begin
                    uart_ready  <=  1;
                    tx_en       <=  0;
                    tx_data     <=  8'b0;
                end
        endcase
    end


endmodule