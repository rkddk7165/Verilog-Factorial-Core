`timescale 1ns/100ps
//tb_Top module for testbench
module tb_Top;

    //reg type
    reg clk, reset_n, m_wr, m_req;
    reg [15:0] m_addr;
    reg [63:0] m_dout;

    //wire type
    wire [63:0] m_din;
    wire m_grant, interrupt;

    //top module instance for testbench
    Top dut(.clk(clk), .reset_n(reset_n), .m_req(m_req), .m_wr(m_wr), .m_addr(m_addr), .m_dout(m_dout), .m_grant(m_grant), .m_din(m_din), .interrupt(interrupt));

   //clock period
   always #5 clk = ~clk;



	initial begin
		
		//initial values
		clk = 1'b0; reset_n = 1'b0;
		m_req = 1'b0;
		m_wr = 1'b0; m_addr = 16'h7020; m_dout = 64'd0;
    
		//reset =1 
		#30;
		reset_n = 1'b1;
    
		//write 1 into operand register
		#100;
		m_req = 1'b1;
		m_wr = 1'b1; m_addr = 16'h7020; m_dout = 64'd12;
    
		//write 1 into intrEn register
		#100;
		m_addr = 16'h7018; m_dout = 64'd1;
    
		//write 1 into opstart register
		#100;
		m_addr = 16'h7000; m_dout = 64'd1;
    
		//read opdone register
		#100;
		m_wr = 1'b0; m_addr = 16'h7010; 
		
		//calculating
		#10000; 
    
		//read result_h 
		m_wr = 1'b0;
		m_addr = 16'h7028;
    
		//write into memory
		#100;
		m_wr = 1'b1;
		m_addr = 16'h000a;
		m_dout = m_din;
    
		//read result_l
		#100;
		m_wr = 1'b0;
		m_addr = 16'h7030;
		
		//write into memory
		#100;
		m_wr = 1'b1;
		m_addr = 16'h000b;
		m_dout = m_din;
	 
		//write 1 into opclear register
		#100;
		m_addr = 16'h7008; m_dout = 64'd1;
		
		//write 0 into opclear register (To restart factorial calculation)
		#100;
		m_addr = 16'h7008; m_dout = 64'd0;
		
		//write 1 into operand register
		#100;
		m_req = 1'b1;
		m_wr = 1'b1; m_addr = 16'h7020; m_dout = 64'd0;
    
		//write 1 into intrEn register
		#100;
		m_addr = 16'h7018; m_dout = 64'd1;
    
		//write 1 into opstart register
		#100;
		m_addr = 16'h7000; m_dout = 64'd1;
    
		//read opdone register
		#100;
		m_wr = 1'b0; m_addr = 16'h7010; 
   
		//calculating
		#10000;
    
		//read result_h 
		m_wr = 1'b0;
		m_addr = 16'h7028;
    
		//write into memory
		#100;
		m_wr = 1'b1;
		m_addr = 16'h00aa;
		m_dout = m_din;
    
		//read result_l
		#100;
		m_wr = 1'b0;
		m_addr = 16'h7030;
		
		//write into memory
		#100;
		m_wr = 1'b1;
		m_addr = 16'h00bb;
		m_dout = m_din;
	 
		//write 1 into opclear register
		#100;
		m_addr = 16'h7008; m_dout = 64'd1;

		//read values of memory
		#100;
		m_wr = 0;
		m_addr = 16'h000a; 
		
		#100; m_addr = 16'h000b;
		
		#100; m_addr = 16'h00aa;
		
		#100; m_addr = 16'h00bb;
		
		#100; m_req = 0; //grant = 0, stop using bus
		
		#300; $stop;
		
	end

endmodule