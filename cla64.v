//64 bits carry look-ahead adder module
module cla64 (a, b, s, ci, co);

	//input values
	input [63:0] a, b;
	input ci;
	
	//output values
	output [63:0] s;
	output co;
	
	//to connect 2 instances of cla32 module
	wire w;
	
	//instances of cla32 module
	cla32 U0_cla32(.a(a[31:0]),.b(b[31:0]),.ci(ci),.s(s[31:0]),.co(w));
	cla32 U1_cla32(.a(a[63:32]),.b(b[63:32]),.ci(w),.s(s[63:32]),.co(co));
	
endmodule
