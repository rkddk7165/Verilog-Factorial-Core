`timescale 1ns/100ps
module tb_FactoCore;

	reg clk, reset_n;
	reg s_sel, s_wr;
	
	reg [15:0] s_addr;
	reg [63:0] s_din;
	
	wire [63:0] s_dout;
	wire interrupt;
	
	FactoCore dut (.clk(clk), .reset_n(reset_n), .s_sel(s_sel), .s_wr(s_wr), .s_addr(s_addr), .s_din(s_din), .s_dout(s_dout), .interrupt(interrupt));
	
	
	always #5 clk = ~clk;
	
	initial begin
		
		//initial values
		clk = 1'b0; reset_n = 1'b0;

		s_wr = 1'b0; s_addr = 16'h7020; s_din = 64'd0;
    
		//reset =1 
		#30;
		reset_n = 1'b1; s_sel = 1'b1;
    
		//write 1 into operand register
		#100;
		s_wr = 1'b1; s_addr = 16'h7020; s_din = 64'd0;
    
		//write 1 into intrEn register
		#100;
		s_addr = 16'h7018; s_din = 64'd1;
    
		//write 1 into opstart register
		#100;
		s_addr = 16'h7000; s_din = 64'd1;
    
		//read opdone register
		#100;
		s_wr = 1'b0; s_addr = 16'h7010; 
		
		//calculating
		#10000; 
    
		//read result_h 
		s_wr = 1'b0;
		s_addr = 16'h7028;
    
		//read result_l
		#100;
		s_wr = 1'b0;
		s_addr = 16'h7030;
		
		//write 1 into opclear register
		#100;
		s_wr = 1'b1;
		s_addr = 16'h7008; s_din = 64'd1;
		
		//write 0 into opclear register (To restart factorial calculation)
		#100;
		s_addr = 16'h7008; s_din = 64'd0;
		
		//write 1 into operand register
		#100;
		s_wr = 1'b1; s_addr = 16'h7020; s_din = 64'd12;
    
		//write 1 into intrEn register
		#100;
		s_addr = 16'h7018; s_din = 64'd1;
    
		//write 1 into opstart register
		#100;
		s_addr = 16'h7000; s_din = 64'd1;
    
		//read opdone register
		#100;
		s_wr = 1'b0; s_addr = 16'h7010; 
   
		//calculating
		#10000;
    
		//read result_h 
		s_wr = 1'b0;
		s_addr = 16'h7028;
    
		//read result_l
		#100;
		s_wr = 1'b0;
		s_addr = 16'h7030;

		//write 1 into opclear register
		#100;
		s_wr = 1'b1;
		s_addr = 16'h7008; s_din = 64'd1;
		
		#100; s_sel = 0;
		
		
		#300; $stop;
		
	end
	
endmodule

