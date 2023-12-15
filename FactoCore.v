//FactoCore module that performs factorial operations
module FactoCore (clk, reset_n, s_sel, s_wr, s_addr, s_din, s_dout, interrupt);

	//input values
	input clk, reset_n;
	input s_sel, s_wr;
	input [15:0] s_addr;
	input [63:0] s_din;
	
	//output values
	output reg [63:0] s_dout;
	output interrupt;
	
	//7 registers and next register for factorial operation
	reg [63:0] opdone, opstart, opclear, operand, result_h, result_l, intrEn;
	reg [63:0] next_opdone, next_opstart, next_opclear, next_result_h, next_result_l, next_operand, next_intrEn;
	
	
	//op_clear and op_start used in multiplier module instance
	reg mul_opclear, mul_opstart;
	
	//op_done signal used in multiplier module instance
	wire mul_opdone;
	
	//register to copy value of operand register
	reg [63:0] reg_operand, next_reg_operand;
	
	//state
	reg [3:0] state, next_state;
	
	wire [63:0] w_result;
	wire [127:0] mul_result;
	
	//offset declaration to check registers
	wire [4:0] offset;
	
	assign offset = s_addr[7:3];
	
	//Encoded state
	parameter IDLE = 4'b0000;
	parameter CHECK_INTREN = 4'b0001;
	parameter READ_OPERAND = 4'b0010;
	parameter CALC_START = 4'b0011;
	parameter CALC_AGAIN = 4'b0100;
	parameter CALCULATING = 4'b0101;
	parameter CHECK_OPERAND = 4'b0110;
	parameter DONE_WAIT = 4'b0111;
	parameter CLEAR =4'b1000;
	
	
	
	always @(posedge clk or negedge reset_n)
		//reset values
		if(!reset_n) begin
				state <= IDLE;
				next_opstart <= 64'd0;
				next_opclear <= 64'd0;
				opdone <= 64'd0;
				next_intrEn <= 64'd0;
				operand <= 64'd0;
				result_h <= 64'd0;
				result_l <= 64'd1;
		end
		//posedge clock
		else begin
		
			//write type registers
			if(s_sel == 1 && s_wr == 1) begin
			case(offset)
				//write 1 into opstart and operate it
				5'b00000 : if(state == READ_OPERAND) begin
										next_opstart <= s_din;
										s_dout <= s_din;
								end
									
								else opstart <= next_opstart;
								
				//write 1 into opclear and operate it
				5'b00001 : if(state == DONE_WAIT || state == CLEAR) begin
									  next_opclear <= s_din;
									  next_opstart <= 64'd0;
									  s_dout <= s_din;
									  end
									  
							  else opclear <= next_opclear;
							  
				//write 1 into intrEn				
				5'b00011 :  if(state == CHECK_INTREN) begin
										next_intrEn <= s_din;
										s_dout <= s_din;
								end
										
								else intrEn <= next_intrEn;
								
								
				//write s_din into operand register	
				5'b00100 : if(state == IDLE) begin
								next_operand <= s_din;
								s_dout <= s_din;
							  end
							  
							  else operand <= next_operand;
								
				default : s_dout <= 64'd0;

			endcase
			end
			
			//read type registers
			else if(s_sel == 1 && s_wr == 0) begin
			
			case(offset)
				5'b00010 : s_dout <= opdone; //read opdone register
				5'b00101 : s_dout <= result_h; //read result_h register
				5'b00110 : s_dout <= result_l; //read result_l register
				
				default : s_dout <= 64'd0;
			endcase
			end
		
			else begin
				next_opstart <= 64'd0;
				next_opclear <= 64'd0;
				opdone <= 64'd0;
				next_intrEn <= 64'd0;
				operand <= 64'd0;
				result_h <= 64'd0;
				result_l <= 64'd1;
			end
		
			//update values at clock rising edge
			state <= next_state;
			opstart <= next_opstart;
			opclear <= next_opclear;
			opdone <= next_opdone;
			operand <= next_operand;
			result_h <= next_result_h;
			result_l <= next_result_l;
			reg_operand <= next_reg_operand;
			intrEn <= next_intrEn;
			
	end
	
	//output interrupt logic
	assign interrupt = intrEn[0] & opdone[0];
	
	
	//////next_State logic/////
	always @(state, s_sel, s_wr, offset, mul_opdone, operand, interrupt, opclear, reg_operand)
		case(state)
			
			IDLE : if(s_sel == 1 && s_wr == 1 && offset == 5'b00100) //write operand
							next_state = CHECK_INTREN;
							
					 else next_state = IDLE;
					 
			CHECK_INTREN : if(s_sel == 1 && s_wr == 1 && offset == 5'b00011) //write intrEn
									next_state = READ_OPERAND;
									
								else next_state = CHECK_INTREN;
							
			READ_OPERAND : if(s_sel == 1 && s_wr == 1 && offset == 5'b00000) //write opstart
									if(operand == 0 || operand == 1)
										next_state = DONE_WAIT;
									
									else next_state = CALC_START;

								else next_state = READ_OPERAND;
								
			CALC_AGAIN : next_state = CALCULATING;
								
			CALC_START : next_state = CALCULATING;
									
			CALCULATING : if(mul_opdone == 1'b1) next_state = CHECK_OPERAND; //if multiplier module operation done, subtract reg_operand
			

								else next_state = CALCULATING;
								
			CHECK_OPERAND : if(reg_operand <= 2) next_state = DONE_WAIT; //if reg_operand = 2, factorial calculation is done
								
								 else next_state = CALC_AGAIN;
		
			DONE_WAIT :  if(opclear[0] == 1) next_state = CLEAR; //opclear operaiton
								
							else next_state = DONE_WAIT;
							
			CLEAR : if(opclear[0] == 0) // clearing value finished
							next_state = IDLE;
						else next_state = CLEAR;
						
			default : next_state = 4'bx;
			
		endcase
		
			
			
	/////next_result logic/////
	always @(mul_opdone, w_result, state, mul_result, result_l, result_h)
	
		//Update the result value at the end of each multiplication
		if(state == CALCULATING) begin
			if(mul_opdone == 1'b1) begin
					next_result_h = mul_result[127:64];
					next_result_l = mul_result[63:0];
			end
			
			else begin next_result_h = result_h;
						  next_result_l = result_l;
			end
		end
						  
		else if (state == CLEAR) begin
		
					//default values of result
					next_result_h = 64'd0;
					next_result_l = 64'd1;
		end
		
		
		else begin next_result_h = result_h;
					  next_result_l = result_l;
		end
		
		
				
	//multiplier instance			
	multiplier U1_multiplier(.clk(clk), .reset_n(reset_n), .multiplier(reg_operand), .multiplicand(w_result),
									 .op_start(mul_opstart), .op_clear(mul_opclear), .op_done(mul_opdone), .result(mul_result));		
				
	//if result_l == 0, use result_h			
	assign w_result = (result_l == 64'b0) ? result_h : result_l;		
				
				
	/////next_reg_operand logic//////			
	always @(state, operand, reg_operand)
		case(state)
		
		
			CALC_START : next_reg_operand = operand;

			
			CALCULATING : 
									next_reg_operand = reg_operand;
									
			
			CHECK_OPERAND : next_reg_operand = reg_operand - 1; //subtract reg_operand
			
			DONE_WAIT : next_reg_operand = reg_operand;
			
			CALC_AGAIN : next_reg_operand = reg_operand;
						
			default : next_reg_operand = 64'b0;
			
		endcase
		
		
	/////next_opdone logic/////
	always @(state)
		if(state == CALC_START)
			next_opdone[1] = 1; // calc start
			
		else if(state == DONE_WAIT)
			next_opdone[1:0] = 2'b11; // calc done
			
		else if(state == CLEAR)
			next_opdone = 64'd0; //default value
			
		else next_opdone = opdone;

	
	/////multiplier op_start and opclear logic/////
	always @(state)
		if(state == CALCULATING) begin
			mul_opstart = 1'b1; mul_opclear = 1'b0; //factorial calculation start
		end
		
		else if(state == CHECK_OPERAND) begin
			mul_opstart = 1'b0; mul_opclear = 1'b1; //multiplier not working when check operand
		end
		
		else begin mul_opstart = 1'b0; mul_opclear = 1'b0; //multiplier not working
		end


endmodule
			
				
				
				
				