# UART_TR-RR

1. UART Transmitter and Receiver Implementation along with reference designs and testbenches.
2. Simulation waveform screenshots are provided.
3. Performance comparisons are done.

# UART Interface

0. Reference: (https://blog.csdn.net/qq_43244515/article/details/124514416)

1. Interface Ports

    ![plot](./UART_Ports.jfif)

    Ports

    input       clk         // 50MHz Clock Signal\n



    rst_n	1	input	System reset signal，negedge
    cmd_i	16	input	[15]：读写指示；1：写，0：读 [14:8]:地址位 [7:0]:数据位
    cmd_rdy	1	output	握手信号ready
    cmd_vld	1	input	握手信号valid
    tx	1	output	uart发送数据端
    rx	1	input	uart接收数据端
    read_vld	1	output	读数据valid
    read_data	8	output	读到的数据

2. UART Frame Composition

    ![plot](./UART_Frame.png)

    1 bit of start bit (0),
    7 bits of data,
    1 bit of parity (to make total # of 1s odd),
    1 bit of stop (1)

3. Interface Bahaviors

