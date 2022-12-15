# UART_TR-RR

1. UART Transmitter and Receiver Implementation along with reference designs and testbenches.
2. Simulation waveform screenshots are provided.
3. Performance comparisons are done.

# UART Interface

0. Reference: (https://blog.csdn.net/qq_43244515/article/details/124514416)

1. Interface Ports

    ![plot](./UART_Ports.jfif)

    Ports

    |input               |clk,            |// 50MHz Clock Signal          |
    |input               |rst_n,          |// Reset Negative              |
    |input   [15:0]      |cmd,            |// [15]     : Read/Write 0/1   |
    |                    |                |// [14:8]   : Address          |
    |                    |                |// [7:0]    : Data             |
    |input               |cmd_valid,      |// Valid Signal for cmd        |
    |output              |cmd_ready,      |// Ready Signal for cmd        |
    |                    |                |                               |
    |output  [7:0]       |read_data,      |// Date Read through UART      |
    |output              |read_valid,     |// Valid Signal for read_data  |
    |                    |                |                               |
    |output              |tx,             |// UART Transitter             |
    |input               |rx,             |// UART Receiver               |

2. UART Frame Composition

    ![plot](./UART_Frame.png)

    1 bit of start bit (0),
    7 bits of data,
    1 bit of parity (to make total # of 1s odd),
    1 bit of stop (1)

3. Interface Bahaviors

