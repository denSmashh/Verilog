`timescale 1ns/1ps

module bcd_adder_tb();

localparam N = 8;

logic [N-1:0] A, B, S;
logic cin, cout;

 
bcd_adder_two_digit #(.N(N))
    i_bcd_adder_two_digit
(
	.A(A),      	// first operand
    .B(B),      	// second operand
    .cin(cin),    	// carry-in
    .S(S),      	// bcd sum
    .cout(cout)    	// carry-out
);


initial begin 

 A = 'd7;
 B = 'd8;
 cin = 0;

 #10;
 A = 'd7;
 B = 'd8;
 cin = 1;

 #20;
 A = 'b0010_1001;   // 29
 B = 'b0001_0111;   // 17
 cin = 0;

 #30;
 A = 'b0101_0000;   // 50
 B = 'b0101_0000;   // 50
 cin = 0;

	
end


endmodule