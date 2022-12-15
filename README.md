# UART_TR-RR

This design is done without using FSM.

1. UART Transmitter and Receiver Implementation along with reference designs and testbenches.
2. Simulation waveform screenshots are provided.
3. Performance comparisons are done.

# UART

This design is done using FSM.

0. Reference: (https://blog.csdn.net/qq_43244515/article/details/124514416)

1. UART Architecture

    ![plot](./UART_Architecture.png)

2. UART Ports

    ![plot](./UART_Ports.jfif)

```
    UART Ports

    input               clk,            // 50MHz Clock Signal  
    input               rst_n,          // Reset Negative  
    input   [15:0]      cmd,            // [15]     : Read/Write 0/1  
                                        // [14:8]   : Address  
                                        // [7:0]    : Data  
    input               uart_valid,     // Valid Signal for UART  
    output              uart_ready,     // Ready Signal for UART  

    output  [7:0]       read_data,      // Date Read through UART  
    output              read_valid,     // Valid Signal for read_data  

    output              tx,             // UART Transitter  
    input               rx              // UART Receiver  
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
```
    UART Interface

    input               clk,            // 50 MHz Clock Signal
    output              uart_clk,       // 115200Hz Clock Signal
    input               rst_n,          // Reset Negative
    input   [15:0]      cmd,            // [15]     : Read/Write 0/1  
                                        // [14:8]   : Address  
                                        // [7:0]    : Data
    input               uart_valid,     // Valid Signal for UART  
    output              uart_ready,     // Ready Signal for UART  

    output  [7:0]       read_data,      // Date Read through UART  
    output              read_valid,     // Valid Signal for read_data

    output  [7:0]       tx_data,        // Data to send
    output              tx_en,          // Enable data to send
    input               tx_done,        // Data sent and done

    input   [7:0]       rx_data,        // Data Received
    input               rx_done,        // Data Received Done Signal
```


3. UART Frame Composition

    ![plot](./UART_Frame.png)

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
    
```
5. State Information
```
    Interface State Information
    Curent State        Next State          Condition

```
```
    Transmitter State Information

    Curent State        Next State          Condition
    IDLE                SEND                uart_valid = 1, uart_ready = 1
                        IDLE                else
    SEND                SEND                Bit Counter < 11 or (uart_valid = 1, uart_ready = 1)
                        WAIT                Bit Counter = 11
```
```
    Receiver State Information

    Curent State        Next State          Condition
    IDLE                RECEIVE             rx = 0
                        IDLE                else
    RECEIVE             RECEIVE             Bit Counter < 11 or rx = 0
                        IDLE                else

```


6. Module Bahaviors
```
    UART Interface

        1.  Generate a slower uart clk at 115200Hz
        2.  Once a cmd packet arrives, decode it and execute
        3.  If it's a read operation, send only the address;
            If it's a write operation, send the address (along with Read/Write Bit) first,
                and then send the data
        4.  
```
