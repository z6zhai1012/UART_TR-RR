# UART_TR-RR

This design is done without concerns of connecting to APB protocol.

1. UART Transmitter and Receiver Implementation along with reference designs and testbenches.
2. Simulation waveform screenshots are provided.
3. Performance comparisons are done.

# UART

This design is designed to connect with APB-UART Bridge.

12/15/2022 Update: Parity bits in RX is of no use. May use it as error signal after modification.

0. Inspired by https://blog.csdn.net/qq_43244515/article/details/124514416

1. UART Architecture

    ![plot](./README_Pictures/UART_Architecture.png)

2. UART Ports

    ![plot](./README_Pictures/UART_Ports.jfif)

```
    UART Ports

    // System Ports
    input               clk,            // 50MHz Clock Signal  
    input               rst_n,          // Reset Negative
    
    // Downlink Slave Interface
    input   [15:0]      cmd,            // [15]     : Read/Write 0/1  
                                        // [14:8]   : Address  
                                        // [7:0]    : Data  
    input               uart_valid,     // Valid Signal for UART  
    output              uart_ready,     // Ready Signal for UART  

    // Uplink Master Interface
    output  [7:0]       read_data,      // Date Read through UART  
    output              read_valid,     // Valid Signal for read_data  

    // Downlink Interface
    output              tx,             // UART Transitter  
    input               rx              // UART Receiver  
```
```
    UART Interface

    // System Ports
    input               clk,            // 50 MHz Clock Signal
    output              uart_clk,       // 115200Hz Clock Signal
    input               rst_n,          // Reset Negative

    // Downlink Slave Interface
    input   [15:0]      cmd,            // [15]     : Read/Write 0/1  
                                        // [14:8]   : Address  
                                        // [7:0]    : Data
    input               uart_valid,     // Valid Signal for UART  
    output              uart_ready,     // Ready Signal for UART  

    // Downlink Master Interfa
    output  [7:0]       tx_data,        // Data to send
    output              tx_en,          // Enable data to send
    input               tx_done         // Data sent and done

    // Uplink Interface
    input   [7:0]       rx_data,        // Data Received
    input               rx_done,        // Data Received Done
    output  [7:0]       read_data,      // Data Read
    output              read_valid      // Data Read Valid
```
```
    UART Transmitter

    input               uart_clk,       // 115200Hz Clock Signal  
    input               rst_n,          // Reset Negative  
    input               tx_en,          // Transmission Enable
    input   [7:0]       tx_in,          // Transmission Data
    output              tx_out,         // Data Out
    output              tx_done         // Transmission Done
```
```
    UART Receiver

    input               uart_clk,       // 115200Hz Clock Signal  
    input               rst_n,          // Reset Negative  
    input               rx_in,          // Date Received
    output  [7:0]       rx_out,         // Data Out
    output              rx_done         // Data Received and Done
```

3. UART Frame Composition

    ![plot](./README_Pictures/UART_Frame.png)

    1 bit of start bit (0),
    8 bits of data,
    1 bit of parity (to make total # of 1s odd),
    1 bit of stop (1)

4. Technical Specs
```
    Bits per Second (BPS)   =   115200
    Clock Frequency         =   50MHz
    Data Width              =   8
    Address Width           =   7
    Command Packet Length   =   16
```
5. Module Bahaviors
```
    UART Interface

        1.  Generate a slower uart clk at 115200Hz
        2.  Once a command packet arrives, decode it and execute
        3.  If it's a read operation, send only the address;
            If it's a write operation, send the address (along with Read/Write Bit) first,
                and then send the data
```
```
    UART Transmitter

        1. Once a UART frame arrives (tx_en is ON), initiate sending process
```
```
    UART Receiver

        1. Once a UART frame arrives (0 is detected), receive and decode the data
        2. After the data receiving process is done, send out the received data
```

6. State Information
```
    Interface State Information
    Current State       Next State          Condition
    IDLE                SEND                uart_valid = 1, rst_n = 1
                        IDLE                else
    SEND                WAIT                
    WAIT                SEND                SEND_NEXT = 1 && tx_done_posedge = 1
                        IDLE                SEND_NEXT = 0 && tx_done_posedge = 1
                        WAIT                tx_done = 0
    
    Interface State Behavior
    Current State       Behavior
    IDLE                uart_clk is generated; uart_ready = 1; tx_en = 0;
                            tx_data = 8'b0; all regs = 0
    SEND                uart_clk is generated; uart_ready = 0; tx_en = 1;
                            if (SEND_NEXT == 1)
                                tx_data <= cmd[7:0]
                                SEND_NEXT <= 0
                            else
                                tx_data <= cmd[15:8]
                                SEND_NEXT <= cmd[15]
    WAIT                uart_clk is generated; uart_ready = 0; tx_en = 0;
```
```
    Transmitter State Information

    Current State       Next State          Condition
    IDLE                SEND                tx_en = 1, rst_n = 1
                        IDLE                else
    SEND                SEND                Bit Counter < 11 or (tx_en = 1)
                        IDLE                Bit Counter = 11

    Transmitter State Behavior
    Current State       Behavior
    IDLE                tx_out = 1; tx_done = 0; all regs = 0
    SEND                if (bit_counter == 0)
                            tx_out = 0
                            tx_done = 0
                            bit_counter = bit_counter + 1
                        else if (bit_counter == 10)
                            tx_out = 1
                            tx_done = 1
                            bit_counter = bit_counter + 1
                        else if (bit_counter == 9)
                            tx_out = odd parity bit
                            tx_done = 0
                            bit_counter = bit_counter + 1
                        else
                            tx_out = tx_in[bit_counter - 1]
                            tx_done = 0
                            bit_counter = bit_counter + 1
```
```
    Receiver State Information

    Current State       Next State          Condition
    IDLE                RECEIVE             rx_in = 0, rst_n = 1
                        IDLE                else
    RECEIVE             RECEIVE             Bit Counter < 8 or rx_in = 0
                        IDLE                Bit Counter = 8

    Receiver State Behavior
    Current State       Behavior
    IDLE                rx_out = 8'b0; rx_done = 0; all regs = 0
    RECEIVE             rx_out[bit_counter] = rx_in; bit_counter = bit_counter + 1
```

7. Take-away

```
    To manage cross clock domain, I employed a posedge edge detector on the faster clock side.
    This makes the return done signal (on slower clock) a done signal on faster clock.
```

# APB-to-UART Bridge

This design is located under UART folder.

0. Inspired by AMBA APB Protocol Document

1. APB2UART Ports



```
    APB2UART

    // System Ports
    input                       PCLK;
    input                       PRESET_n;

    // Basic APB Ports
    input   [ADDR_WIDTH-1:0]    PADDR;      // Address
    input                       PSEL;       // 1 for being selected
    input                       PENABLE;    // 1 to enable transmission
    input                       PWRITE;     // 1 for write, 0 for read
    input   [DATA_WIDTH-1:0]    PWDATA;
    output                      PREADY;
    output  [DATA_WIDTH-1:0]    PRDATA;

    // UART Interface Ports
    output  [CMD_PKT_LEN-1:0]   cmd,            // [15]     : Read/Write 0/1  
                                                // [14:8]   : Address  
                                                // [7:0]    : Data  
    output                      uart_valid,     // Valid Signal for UART  
    input                       uart_ready,     // Ready Signal for UART  
    input   [DATA_WIDTH-1:0]    read_data,      // Date Read through UART  
    input                       read_valid,     // Valid Signal for read_data  
    
    // Optional ABP Port; Not implemented in our design
    output                      PSLVERR;    // Slave Error Message
    
    // Advanced APB Ports; Not implemented in our design
    input   [2:0]               PROT;
    input   [DATA_WIDTH/8-1:0]  PSTRB;
    input                       PWAKEUP;
    input   [USER_REQ_WIDTH-1:0]    PAUSER;
    input   [USER_DATA_WIDTH-1:0]   PWUSER;
    input   [USER_DATA_WIDTH-1:0]   PRUSER;
    input   [USER_RESP_WIDTH-1:0]   PBUSER;
```

2. Technical Specs

```
    ADDR_WIDTH      =   7
        : Max width is 32, depending on peripheral bus bridge unit
          In our case, we only use least significant 7 bits
    DATA_WIDTH      =   8
        : Can be 8, 16, 32 bits wide.
          We will use 8 for easier implementation with UART
    
```

3. Module Behaviors
```
    Downlink:
        1. Receive ADDR, WDATA, WRITE once ENABLE and SEL are 1
        2. Once a APB packet arrives, convert it into UART command
        3. Send cmd and uart_valid = 1; Wait until UART ready signal is 1
    
    Uplink:
        1. Once read_data and read_valid is ready, then send it over APB channel
```

4. APB Master State Information

    ![plot](./README_Pictures/APB2UART_STATES.png)

5. APB Slave State Information
```
    State Transition Conditions
    Current State   Next State      Condition
    IDLE            Send            PSEL = 1; PENABLE = 1
                    IDLE            else
    SEND            IDLE            uart_ready = 1
                    SEND            else

    State Behaviors
    Current State   Behaviors
    IDLE            PREADY = 1; cmd = 0; uart_valid = 0
    SEMD            PREADY = 0; cmd = {PWRITE, PADDR, PWDATA}; uart_valid = 1
```