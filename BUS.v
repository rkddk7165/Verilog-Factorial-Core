module BUS (clk, reset_n, m_req, m_wr, m_addr, m_dout, s0_dout, s1_dout, m_grant, m_din, s0_sel, s1_sel, s_addr, s_wr, s_din);

	//input values declaration
	input clk, reset_n;
	
	input m_req;
	input m_wr;
	
	input [15:0] m_addr;
	
	input [63:0] m_dout;
	
	input [63:0] s0_dout, s1_dout;
	
	//output values declaration
	output m_grant;
	output reg [63:0] s_din;
	output reg [63:0] m_din;
	output s0_sel, s1_sel;
	output reg s_wr;
	output reg [15:0] s_addr;
	
	//s_sel next values
	reg next_s0_sel, next_s1_sel;	
	
	//arbiter module instance
	arbiter U0_arbiter(.clk(clk), .reset_n(reset_n), .m_req(m_req), .m_grant(m_grant));
	
	//address_decoder module instance
	address_decoder U4_address_decoder (.address(s_addr), .s0_sel(s0_sel), .s1_sel(s1_sel), .m_req(m_req));
	
	
	//next_s_sel update at clock rising edge
	always @(posedge clk)
		
		 begin
			next_s0_sel <= s0_sel;
			next_s1_sel <= s1_sel;
		end
		
		
	//BUS works only when m_grant == 1
	always@(m_grant, m_wr, m_dout, m_addr) begin
		
		if(m_grant == 1) begin
			s_wr <= m_wr;
			s_din <= m_dout;
			s_addr <= m_addr;
		end
		
		else begin
			s_wr <= 1'b0;
			s_din <= 64'b0;
			s_addr <= 16'h0;
			
		end
	end
	
	//select slave and output corresponding slave values
	always@ (next_s0_sel, next_s1_sel, s0_dout, s1_dout)
		
		if(next_s0_sel == 1 && next_s1_sel == 0)
			m_din <= s0_dout;
		else if(next_s1_sel == 1 && next_s0_sel == 0)
			m_din <= s1_dout;
		else
			m_din <= 32'b0;
			
			
endmodule
	