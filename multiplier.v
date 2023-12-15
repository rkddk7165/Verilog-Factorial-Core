///multiplier module
module multiplier(clk, reset_n, multiplier, multiplicand, op_start, op_clear, op_done, result);

	//input declaration
   input clk, reset_n;
   input op_start, op_clear;
   input [63:0] multiplier, multiplicand;
  
	//output declaration
   output reg [127:0] result;
	output reg op_done;
	
	reg [127:0] next_result;
	
	reg [63:0] reg_multiplicand;
  
   reg [64:0] reg_multiplier;
   reg [64:0] next_reg_multiplier;

   reg [1:0] state;
   reg [1:0] next_state;
  
   reg [63:0] count;
   reg [63:0] next_count;
  

	wire w0;
	
	wire [127:0] w_result;

	assign w_result[63:0] = result[63:0]; //declaration for wire to update result value

  parameter IDLE = 2'b00;
  parameter MULTIPLYING = 2'b01;
  parameter DONE = 2'b10;

  
   //when posedge clk, values are updated
	//when negedge reset_n, all values are initialized
  always @(posedge clk or negedge reset_n)
   if (!reset_n) begin
      state <= IDLE;
      reg_multiplier <= 65'b0;
      count <= 64'h8000_0000_0000_0000;
      result <= 128'b0;
   end
    

   else begin
      state <= next_state;
      reg_multiplier <= next_reg_multiplier;
      count <= next_count;
      result <= next_result;
   end
	
	
	
	//implement of next_reg_multiplier logic
   always @(state, reg_multiplier, multiplier)
   case (state)
      IDLE :
         next_reg_multiplier = {multiplier[63:0], 1'b0}; // When checking the [0] bit, assume the value of the previous bit is 0 and compare it.
      
      MULTIPLYING :
         next_reg_multiplier = {reg_multiplier[64], reg_multiplier[64:1]}; //1 bit arithmetic right shift
      
      DONE :
         next_reg_multiplier = reg_multiplier; //not changed
         
      default : next_reg_multiplier = 65'bx;
      
   endcase


    
	 //Implement the part of the 1 cycle that adds or subtracts multiplicand or adds nothing.
   always @ (reg_multiplicand, multiplicand, reg_multiplier) begin
   if(reg_multiplier[1] == 1'b1 && reg_multiplier[0] == 1'b0) begin
		
   reg_multiplicand = ~(multiplicand); //1's complement (SUB multiplicand)
   end
   
   else if(reg_multiplier[1] == 1'b0 && reg_multiplier[0] == 1'b1) begin
   reg_multiplicand = multiplicand; //(Add multiplicand)
   end
   
   else if(reg_multiplier[1] == 1'b0 && reg_multiplier[0] == 1'b0) begin
   reg_multiplicand = 64'b0; //add nothing (only shift)
   end
   
   else if(reg_multiplier[1] == 1'b1 && reg_multiplier[0] == 1'b1) begin
   reg_multiplicand = 64'b0; //add nothing (only shift)
   end
	
	else reg_multiplicand = 64'bx;
   
   end
   
   //ci value becomes 1 only when multiplicand is subtracted, and in other cases it becomes 0.
  assign w0 = (reg_multiplier[1] == 1'b1 && reg_multiplier[0] == 1'b0);



	//Add multiplicand or Sub multiplicand or add nothing in 1 cycle
  cla64 U0_cla64(.a(reg_multiplicand[63:0]), .b(result[127:64]), .ci(w0), .s(w_result[127:64]), .co());

   


    //implement of next_result logic
   always @(reg_multiplier, state, count, result, next_result, w_result, multiplier, multiplicand, op_clear)
      case (state)
         IDLE :
               next_result = 128'b0; //initialization
      
         MULTIPLYING :    
            if (count == 64'b0) // 64 cycles are done
               next_result = result;
            else
               next_result={w_result[127], w_result[127:1]}; // 1 bit arithmetic right shift is performed per 1 cycle
         
         DONE :
               next_result = result; //not changed
               
      default : next_result = 128'bx;
      
   endcase

    

    //implement of next_count logic
   always @(state, count, next_count, op_clear)
      case(state)
         IDLE : 
               next_count = 64'h8000_0000_0000_0000; //initialization
            
         MULTIPLYING : 
               next_count = {1'b0, count[63:1]}; // 1 bit logical right shift
      
      
         DONE:
            
               next_count = count; //not changed 
			
			default : next_count = 64'hx;
  endcase
  
  
     always @(op_clear, count)
      if (op_clear)
			op_done = 0; //initialization
			
      else if (count == 64'b0)
			op_done = 1; //multiplication is done
			
		else if (state == IDLE)
			op_done = 0;
			
      else 
			op_done = 0;

   //implement of next_state logic
   always @(state, op_start, op_clear, op_done)
      case (state)
         IDLE :
            if (op_start == 1'b1)
               next_state = MULTIPLYING; //multiplication start
            
            else
               next_state = IDLE;
         
         MULTIPLYING :
            if (op_clear == 1'b1) 
               next_state = IDLE; //initialization
            
            else if (op_done == 1'b1) 
               next_state = DONE; //multiplication is done
            
            else
               next_state = MULTIPLYING; //multiplication in progress
            
         DONE :
            if (op_clear == 1'b1)
               next_state = IDLE; //initialization
					
				
            else 
               next_state = DONE;
            
         default : next_state = 2'bx;
      endcase
		


endmodule

