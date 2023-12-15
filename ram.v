//ram module for reading and writing memory values of the input address
module ram(clk, cen, wen, s_addr, s_din, s_dout);

	//input values declaration
   input clk;
   input cen, wen;
   input [7:0] s_addr;
   input [63:0] s_din;
	
	//output value declaration
   output reg [63:0] s_dout;
	
	//64 bit and 256 storage size memory declaration
   reg [63:0] mem [0:255];
	
	//declarer integer i to initialize memory
   integer i;
   
	
	//initialize memory
	initial begin

		for(i=0; i < 256; i = i+1) begin
		mem[i] = 64'b0;

		end
	end


	//read and write implement
   always@(posedge clk) begin
	
		//write operation
      if(cen == 1 && wen == 1) begin
         mem[s_addr] <= s_din;
			s_dout <= 64'b0;
		end
      
		//read operation
      else if(cen == 1 && wen == 0) 
         s_dout <= mem[s_addr];

		else // cen == 0 -> dout = 0
			s_dout <= 64'b0;
	end
endmodule
