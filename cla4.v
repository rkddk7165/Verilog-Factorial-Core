//4bits cla module
module cla4(a, b, ci, s, co);

	//input values
	input [3:0] a, b;
	input ci;
	
	//output values
	output [3:0] s;
	output co;
	
	//to connect 4 instances of fa_v2 module
	wire [3:0] c;

//instances of fa_v2 and clab4 modules
fa_v2 fa0 (.a(a[0]), .b(b[0]), .ci(ci), .s(s[0]));
fa_v2 fa1 (.a(a[1]), .b(b[1]), .ci(c[0]), .s(s[1]));
fa_v2 fa2 (.a(a[2]), .b(b[2]), .ci(c[1]), .s(s[2]));
fa_v2 fa3 (.a(a[3]), .b(b[3]), .ci(c[2]), .s(s[3]));
clb4 clb4 (.a(a), .b(b), .ci(ci), .c1(c[0]), .c2(c[1]), .c3(c[2]), .co(co));

endmodule
