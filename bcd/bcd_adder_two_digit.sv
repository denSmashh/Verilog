// BCD - binary-codded decimal
// example: 0101_0011 = d'53   0001_0001 = d'11
// sum example: 1000 + 0111 = d'15 = 0001_0101

// schematic (example: adder two 2-digit arguments):
//
//
//                  A[7:4] B[7:4]       A[3:0] B[3:0]       
//                      ADDER               ADDER <-------- cin
//                        |                   |
//                 correct circuit     correct circuit
// cout <----------- (if sum > 9)        (if sum > 9)                       
//                        |                   |
//                     S[7:4]               S[3:0]
//


module bcd_adder_two_digit #(parameter N = 8)
(
    input  logic [N-1:0]  A,      // first operand
    input  logic [N-1:0]  B,      // second operand
    input  logic          cin,    // carry-in
    output logic [N-1:0]  S,      // bcd sum
    output logic          cout    // carry-out
);


  logic [N/2:0] sum_l;
  logic [N/2:0] sum_h;
  logic sum_l_cout; 

// first half sum  
  assign sum_l = A[N/2-1:0] + B[N/2-1:0] + cin;
  
  assign S[N/2-1:0] = (sum_l > 'd9) ? sum_l + 4'd6 : sum_l;
  
  assign sum_l_cout = (sum_l > 'd9) ? 'b1 : 'b0;


// second half sum
  assign sum_h = A[N-1:N/2] + B[N-1:N/2] + sum_l_cout;
  
  assign S[N-1:N/2] = (sum_h > 'd9) ? sum_h + 4'd6 : sum_h;
  
  assign cout = (sum_h > 'd9) ? 'b1 : 'b0;  
  

endmodule