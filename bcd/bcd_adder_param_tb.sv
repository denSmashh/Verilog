`timescale 1ns/1ps

module bcd_adder_param_tb();

localparam N_DIGIT = 4;

logic [N_DIGIT*4-1:0] A, B;
logic [N_DIGIT*4+3:0] S;
logic cin;

 
bcd_adder_param #(.N_DIGIT_OPERANDS(N_DIGIT))
    i_bcd_adder_param
(
	.A(A),      	// first operand
    .B(B),      	// second operand
    .cin(cin),    	// carry-in
    .S(S)      	    // bcd sum
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

 #40;
 A = 'b0101_0000;   // 50
 B = 'b0101_0000;   // 50
 cin = 1;

 #50;
 A = 'b1001_1001_1001;   // 999
 B = 'b1001_1001_1001;   // 999
 cin = 0;


 #50;
 A = 'b1001_1001_1001_1001;   // 9999
 B = 'b1001_1001_1001_1001;   // 9999
 cin = 0;

end


endmodule