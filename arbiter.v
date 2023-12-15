//arbiter module for determining m_grant value according to m_req
module arbiter (clk, reset_n, m_req, m_grant);

	//input values declaration
	input clk, reset_n;
	input m_req;
	
	//output values declaration
	output reg m_grant;
	
	//state declaration
	reg state, next_state;
	
	//Encoded state
	parameter IDLE = 1'b0;
	parameter M_GRANT = 1'b1;
	
	//resettable d flip-flop (reset -> state : IDLE)
	always @(posedge clk or negedge reset_n)
	
		if(!reset_n)
			state <= IDLE;
		else
			state <= next_state;
	
	//next_state logic
	always @(m_req, state) begin
		case (state)
			IDLE :
				if(m_req == 1)
					next_state <= M_GRANT;
					
				else
					next_state <= state;
					
			M_GRANT :
				if(m_req == 0)
					next_state <= IDLE;
					
				else
					next_state <= state;
					
			default: next_state <= 1'b0;
			
		endcase
	end
	
	
	//output logic
	always @(state)
		case (state)
			IDLE : 	 m_grant <= 0;
			
			M_GRANT : m_grant <= 1;
			
			default: next_state <= 1'b0;
				
		endcase
	
endmodule

	



