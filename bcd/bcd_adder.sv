// BCD - binary-codded decimal
// example: 0101_0011 = d'53   0001_0001 = d'11
// sum example: 1000 + 0111 = d'15 = 0001_0101

// module "bcd_adder" add two 1-digit values

module bcd_adder
(
    input  logic [3:0]  A,      // first operand
    input  logic [3:0]  B,      // second operand
    input  logic        cin,    // carry-in
    output logic [3:0]  S,      // bcd sum
    output logic        cout    // carry-out
);


  logic [4:0] sum;

  assign sum = A + B + cin;
  assign S = (sum > 'd9) ? sum + 4'd6 : sum;
  assign cout = (sum > 'd9) ? 'b1 : 'b0;

endmodule