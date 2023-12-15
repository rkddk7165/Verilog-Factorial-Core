`timescale 1ns/100ps
//testbench module for ram
module tb_ram;

	//input values
	reg clk, cen, wen;
	reg [7:0] addr;
	reg [63:0] din;
	
	//output values
	wire [63:0] dout;

	//instantiate for testbench
	ram dut (.clk(clk), .cen(cen), .wen(wen), .s_addr(addr), .s_din(din), .s_dout(dout));
	
	always #5 clk = ~clk;
	
	initial begin
	
	clk = 1; cen = 0; wen = 0; addr = 8'h0; din = 64'h0; //initial value
	
	#8;
	
	cen = 1; wen = 1; addr = 8'haa; din = 64'h1; //write into memory operation
	
	#10;
	
	addr = 8'hbb; din = 64'h2; //write into memory operation
	
	#10;
	
	cen = 1; wen = 0; addr = 8'haa; din = 64'h0; //read from memory operation
	
	#10;
	
	addr = 8'hbb; //read from memory operation
	
	#10;
	
	cen = 0; //cen == 0 -> dout = 0
	
	#10;
	
	$stop;
	
	end
	
endmodule

	
	