//32 bits carry look-ahead adder module
module cla32 (a, b, s, ci, co);

	//input values
	input[31:0] a, b;
	input ci;
	
	//output values
	output [31:0] s;
	output co;
	
	//to connect 8 instances of cla4 module
	wire w0, w1, w2, w3, w4, w5, w6;
	
	//instances of cla4 module
	cla4 U0_cla4(.a(a[3:0]), .b(b[3:0]), .s(s[3:0]), .ci(ci), .co(w0));
	cla4 U1_cla4(.a(a[7:4]), .b(b[7:4]), .s(s[7:4]), .ci(w0), .co(w1));
	cla4 U2_cla4(.a(a[11:8]), .b(b[11:8]), .s(s[11:8]), .ci(w1), .co(w2));
	cla4 U3_cla4(.a(a[15:12]), .b(b[15:12]), .s(s[15:12]), .ci(w2), .co(w3));
	cla4 U4_cla4(.a(a[19:16]), .b(b[19:16]), .s(s[19:16]), .ci(w3), .co(w4));
	cla4 U5_cla4(.a(a[23:20]), .b(b[23:20]), .s(s[23:20]), .ci(w4), .co(w5));
	cla4 U6_cla4(.a(a[27:24]), .b(b[27:24]), .s(s[27:24]), .ci(w5), .co(w6));
	cla4 U7_cla4(.a(a[31:28]), .b(b[31:28]), .s(s[31:28]), .ci(w6), .co(co));
	
endmodule
