//4-bits carry look-ahead block module
module clb4(a, b, ci, c1, c2, c3, co);

	input [3:0] a, b;
	input ci;
	output c1, c2, c3, co;

	wire [3:0] g, p;
	
	wire w0_c1;			
	wire w0_c2, w1_c2;			
	wire w0_c3, w1_c3, w2_c3;			
	wire w0_co, w1_co, w2_co, w3_co; 	
	//generate
	_and2 U0_and2(a[0], b[0], g[0]);		
	_and2 U1_and2(a[1], b[1], g[1]);		
	_and2 U2_and2(a[2], b[2], g[2]);		
	_and2 U3_and2(a[3], b[3], g[3]);		
	
	//propagate
	_or2 	U4_or2(a[0], b[0], p[0]);		
	_or2 	U5_or2(a[1], b[1], p[1]);		
	_or2 	U6_or2(a[2], b[2], p[2]);		
	_or2 	U7_or2(a[3], b[3], p[3]);		
	
	//c1=g[0]|(p[0]&ci)
	_and2 U8_and2(p[0], ci, w0_c1);		
	_or2 U9_or2(g[0], w0_c1, c1);			
	
	//c2=g[1]|(p[1]&g[0])|(p[1]&p[0],ci)
	_and2 U10_and2(p[1], g[0], w0_c2);	
	_and3 U11_and3(p[1], p[0], ci, w1_c2 ); 
	_or3 U12_or3(g[1], w0_c2, w1_c2, c2);	 
	
	//c3=g[2]|(p[2]&g[1])|(p[2]&p[1],g[0])|(p[2]&p[1],p[0]&ci)
	_and2 U13_and2(p[2], g[1], w0_c3);	
	_and3 U14_and3(p[2], p[1], g[0], w1_c3);
	_and4 U15_and4(p[2], p[1], p[0], ci, w2_c3);
	_or4 U16_or4(g[2], w0_c3, w1_c3, w2_c3, c3);
	
	//co=g[3]|(p[3]&g[2])|(p[3]&p[2],g[1])|(p[3]&p[2]&p[1]&g[0])|(p[3]&p[2]&p[1]&p[0]&ci)
	_and2 U17_and2(p[3], g[2], w0_co);				
	_and3 U18_and3(p[3], p[2], g[1], w1_co);		
	_and4 U19_and4(p[3], p[2], p[1], g[0], w2_co);
	_and5 U20_and6(p[3], p[2], p[1], p[0], ci, w3_co);
	_or5 U21_or6(g[3], w0_co, w1_co, w2_co, w3_co, co);
	
endmodule
