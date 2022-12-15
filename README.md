# UART_TR-RR

1. UART Transmitter and Receiver Implementation along with reference designs and testbenches.
2. Simulation waveform screenshots are provided.
3. Performance comparisons are done.

# UART Interface

1. Interface Ports

    ![plot](./UART_Ports.jfif)

2. UART Frame Composition

    ![plot](./UART_Frame.png)

    1 bit of start bit (0),
    7 bits of data,
    1 bit of parity (to make total # of 1s odd),
    1 bit of stop (1)

3. Interface Bahaviors

    