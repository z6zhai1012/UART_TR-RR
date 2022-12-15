# UART_TR-RR

1. UART Transmitter and Receiver Implementation along with reference designs and testbenches.
2. Simulation waveform screenshots are provided.
3. Performance comparisons are done.

# UART Interface

0. Reference: (https://blog.csdn.net/qq_43244515/article/details/124514416)

1. Interface Ports and Architecture

    ![plot](./UART_Ports.jfif)

    ![plot](./UART_Architecture.png)

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
    input               rx,             // UART Receiver  
```
```
    UART Transmitter
```

2. UART Frame Composition

    ![plot](./UART_Frame.png)

    1 bit of start bit (0),
    8 bits of data,
    1 bit of parity (to make total # of 1s odd),
    1 bit of stop (1)

3. Technical Specs
```
    Bits per Second (BPS)   =   115200
    Clock Frequency         =   50MHz
    Data Width              =   8
    Address Width           =   7
```
4. State Information
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


5. Interface Bahaviors
```
    State
```
