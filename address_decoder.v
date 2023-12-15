//address_decoder module for determining slave by checking the range of address
module address_decoder (address, m_req, s0_sel, s1_sel);

	//input value declaration
	input [15:0] address;
	input m_req;
	
	//output values declaration
	output reg s0_sel, s1_sel;
	
	//check the range of address to determine slave
	always @(address) begin
		if(m_req == 1'b1) begin
			if((address >= 16'h0000) && (address <= 16'h07FF))
				{s0_sel, s1_sel} = 2'b10;
			
			else if((address >= 16'h7000) && (address <= 16'h71FF)) 
				{s0_sel, s1_sel} = 2'b01;

			else
				{s0_sel, s1_sel} = 2'b00;
		end
		
		else {s0_sel, s1_sel} = 2'b00;

	end
	
endmodule

