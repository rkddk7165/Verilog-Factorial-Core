module tb_BUS;
	
	//reg values declaration
	reg clk, reset_n;
	reg m_req;
	reg m_wr;
	reg [15:0] m_addr;
	reg [63:0] m_dout;
	reg [63:0] s0_dout, s1_dout;
	
	//wire values declaration
	wire m_grant;
	wire [63:0] s_din;
	wire [63:0] m_din;
	wire s0_sel, s1_sel;
	wire s_wr;
	wire [15:0] s_addr;
	
	//BUS module instance for testbench
	BUS dut (clk, reset_n, m_req, m_wr, m_addr, m_dout, s0_dout, s1_dout,  m_grant, m_din, s0_sel, s1_sel, s_addr, s_wr, s_din);
	
	 always #5 clk = ~clk;
	 
	 initial begin
	 
		//initial values
			clk = 1; reset_n = 0; m_req = 0;
			m_addr = 16'h0;
			m_wr = 0;
			m_dout = 64'h0;
			s0_dout = 64'h0; s1_dout = 64'h0;
	
		//When slave 0 is selected
		#8; 
			reset_n = 1; m_req = 1;
			m_addr = 16'h0600;
			m_wr = 1;
			m_dout = 64'hffff;
			s0_dout = 64'haaaa; s1_dout = 64'hbbbb;
			
		//When slave 1 is selected
		#20; 
			m_addr = 16'h7020;
	
		//When no slave is selected
			#20; 
			m_addr = 16'hfff0;
	
		//m_req -> m_grant = 0 : stop using BUS
		#20; 
			m_req = 0;
	
		#20;
	
			$stop;
	
	end
	
endmodule

	 
	
	
	

