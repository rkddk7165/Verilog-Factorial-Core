//full adder module
module fa_v2(a,b,ci,s);
input a,b,ci;
output s;
wire w0;
_xor2 xor20(.a(a), .b(b), .y(w0));
_xor2 xor21(.a(w0), .b(ci), .y(s));
endmodule