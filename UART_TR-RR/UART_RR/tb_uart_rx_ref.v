 
// *******************************************************************************************************
// ** 作者 ： 孤独的单刀                                                   			
// ** 邮箱 ： zachary_wu93@163.com
// ** 博客 ： https://blog.csdn.net/wuzhikaidetb 
// ** 日期 ： 2022/07/29	
// ** 功能 ： 1、对基于FPGA的串口接收驱动模块的测试testbench
//			  2、通过构建一个task来模拟上位机时序发送数据给串口接收驱动，观察该模块能否成功接收数据。
//			  3、依次发送4个随机的8bit数据                                           									                                                                          			
// *******************************************************************************************************			
 
`timescale 1ns/1ns	//定义时间刻度
 
//模块、接口定义
module tb_uart_rx_ref();
 
reg 			sys_clk			;			
reg 			sys_rst_n		;			
reg 			uart_rxd		;
 
wire 			uart_rx_done	;		
wire	[7:0]	uart_rx_data	;
 
localparam	integer	BPS 	= 'd230400				;	//波特率
localparam	integer	CLK_FRE = 'd50_000_000			;	//系统频率50M
localparam	integer	CNT     = 1000_000_000 / BPS	;	//计算出传输每个bit所需要的时间，单位：ns
//初始时刻定义
initial begin	
	$timeformat(-9, 0, " ns", 10);	//定义时间显示格式	
	sys_clk	=1'b0;	
	sys_rst_n <=1'b0;		
	uart_rxd <=1'b1;
	
	#20 //系统开始工作
	sys_rst_n <=1'b1;
	
	#3000
	rx_byte({$random} % 256);		//生成8位随机数1
	rx_byte({$random} % 256);		//生成8位随机数2
	rx_byte({$random} % 256);       //生成8位随机数3
	rx_byte({$random} % 256);       //生成8位随机数4	
	#60	$finish();
end
//每当成功接收一个BYTE的数据，就在测试端窗口打印出来
always @(posedge sys_clk)begin
	if(uart_rx_done)begin
		$display("@time%t", $time);	
		$display("rx : 0x%h",uart_rx_data);
	end
end
//定义任务，每次发送的数据10 位(起始位1+数据位8+停止位1)
task rx_byte(
	input [7:0] data
);
	integer i; //定义一个常量
	//用 for 循环产生一帧数据，for 括号中最后执行的内容只能写 i=i+1
	for(i=0; i<10; i=i+1) begin
		case(i)
		0: uart_rxd <= 1'b0;		//起始位
		1: uart_rxd <= data[0];		//LSB
		2: uart_rxd <= data[1];
		3: uart_rxd <= data[2];
		4: uart_rxd <= data[3];
		5: uart_rxd <= data[4];
		6: uart_rxd <= data[5];
		7: uart_rxd <= data[6];
		8: uart_rxd <= data[7];		//MSB
		9: uart_rxd <= 1'b1;		//停止位
		endcase
		#CNT; 						//每发送 1 位数据延时
	end		
endtask 							//任务结束
//设置主时钟
always #10 sys_clk <= ~sys_clk;		//时钟20ns,50M
 
//例化被测试的串口接收驱动
uart_rx_ref
#(
	.BPS			(BPS			),		
	.CLK_FRE		(CLK_FRE		)			
)
uart_rx_ref_inst(
	.sys_clk		(sys_clk		),			
	.sys_rst_n		(sys_rst_n		),			
	.uart_rxd		(uart_rxd		),			
	.uart_rx_done	(uart_rx_done	),		
	.uart_rx_data	(uart_rx_data	)	
);
endmodule 