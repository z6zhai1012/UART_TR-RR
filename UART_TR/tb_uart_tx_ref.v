 
// *******************************************************************************************************
// ** 作者 ： 孤独的�?�刀                                                   			
// ** 邮箱 ： zachary_wu93@163.com
// ** �?�客 ： https://blog.csdn.net/wuzhikaidetb 
// ** 日期 ： 2022/07/29	
// ** 功能 ： 1�?对基于FPGA的串�?��?��?驱动模�?�的测试testbench
//			  2�?�?��?一个8bit的�?机数�?�，观测其波形是�?�符�?�UART时�?                                        									                                                                          			
// *******************************************************************************************************		
 
`timescale 1ns/1ns	//定义时间刻度
 
module tb_uart_tx_ref();
 
reg 			sys_clk			;			
reg 			sys_rst_n		;			
reg [7:0]		uart_tx_data	;
reg 			uart_tx_en		;
			
wire 	 		uart_txd		;
 
parameter	integer	BPS 	= 'd9600		;			//波特率
parameter	integer	CLK_FRE = 'd50_000_000	;			//系统频率50M
 
localparam	integer	BIT_TIME = 'd1000_000_000 / BPS ;	//计算出传输�?个bit所需�?的时间
 
initial begin	
	sys_clk <=1'b0;	
	sys_rst_n <=1'b0;		
	uart_tx_en <=1'b0;
	uart_tx_data <=8'd0;				
	#80 										//系统开始工作
		sys_rst_n <=1'b1;
		
	#200
		@(posedge sys_clk);
		uart_tx_en <=1'b1;	
		uart_tx_data <= ({$random} % 256);		//�?��?8�?�?机数�?�
	#20	
		uart_tx_en <=1'b0;
	
	#(BIT_TIME * 10)							//�?��?1个BYTE需�?10个bit
	#200 $finish;								//结�?�仿真
end
 
always #10 sys_clk=~sys_clk;					//定义主时钟，周期20ns，频率50M
 
//例化�?��?驱动模�?�
uart_tx_ref #(
	.BPS			(BPS			),		
	.CLK_FRE		(CLK_FRE		)		
)	
uart_tx_ref_inst(	
	.sys_clk		(sys_clk		),			
	.sys_rst_n		(sys_rst_n		),
	
	.uart_tx_data	(uart_tx_data	),			
	.uart_tx_en		(uart_tx_en		),		
	.uart_tx_done	(uart_tx_done	),		
	.uart_txd		(uart_txd		)	
);
 
endmodule 