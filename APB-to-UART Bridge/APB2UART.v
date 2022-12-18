// *****************************************************************************
// Author: Zhen Zhai
// Date: 12/17/2022
// 
// Module Name: APB2UART
//      1. A simple implementation of APB-to-UART Bridge
//
// *****************************************************************************

module APB2UART
#(
    parameter   ADDR_WIDTH  =   7,
    parameter   DATA_WIDTH  =   8
)
(
    // System Ports
    input                       PCLK,
    input                       PRESET_n,

    // Basic APB Ports
    input   [ADDR_WIDTH-1:0]        PADDR,      // Address
    input                           PSEL,       // 1 for being selected
    input                           PENABLE,    // 1 to enable transmission
    input                           PWRITE,     // 1 for write, 0 for read
    input   [DATA_WIDTH-1:0]        PWDATA,
    output  reg                     PREADY,

    output  reg [DATA_WIDTH-1:0]    PRDATA,     // Uplink Data

    // UART Interface Ports
    output  reg [ADDR_WIDTH + DATA_WIDTH:0]   cmd,  // [15]     : Read/Write 0/1  
                                                    // [14:8]   : Address  
                                                    // [7:0]    : Data  
    output  reg                 uart_valid,     // Valid Signal for UART  
    input                       uart_ready,     // Ready Signal for UART  
    
    input   [DATA_WIDTH-1:0]    read_data,      // Date Read through UART  
    input                       read_valid      // Valid Signal for read_data  
);
    localparam  [1:0]   IDLE    =   2'b01;
    localparam  [1:0]   SEND    =   2'b10;

    reg     [2:0]   current_state;

    // FSM Transition
    always @ (posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n)
            current_state   <=  IDLE;
        else begin
            case (current_state)
                IDLE:
                    begin
                        if ((PSEL == 1) && (PENABLE == 1))
                            current_state   <=  SEND; 
                    end
                SEND: begin
                    if (uart_ready == 1)
                        current_state   <=  IDLE;
                    else
                        current_state   <=  SEND;
                end
                default:
                    current_state   <=  IDLE;
            endcase
        end
    end

    // FSM Behaviors
    always @ (*) begin
        case (current_state)
            IDLE:
                begin
                    PREADY      <=  1;
                    cmd         <=  0;
                    uart_valid  <=  0;
                end
            SEND:
                begin
                    PREADY      <=  1;
                    cmd         <=  {PWRITE, PADDR, PWDATA};
                end
            default:
                begin
                    PREADY      <=  0;
                    cmd         <=  0;
                    uart_valid  <=  0;
                end
        endcase
    end

    // Uplink Transmission (PRDATA)
    always @ (posedge PCLK or negedge PRESET_n) begin
        if (!PRESET_n)
            PRDATA  <=  0;
        else if (read_valid == 1)
            PRDATA  <=  read_data;
        else
            PRDATA  <=  0;
    end
endmodule