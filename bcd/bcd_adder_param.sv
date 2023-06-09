// BCD - binary-codded decimal
// example: 0101_0011 = d'53   0001_0001 = d'11
// sum example: 1000 + 0111 = d'15 = 0001_0101

// schematic for papameterized bcd adder
// module bcd_adder_param based on module bcd_adder(add two 1-digit values) 


module bcd_adder_param #(parameter N_DIGIT_OPERANDS = 3)
    (
        input  logic [N_DIGIT_OPERANDS*4-1:0]  A,       // first operand
        input  logic [N_DIGIT_OPERANDS*4-1:0]  B,       // second operand
        input  logic                           cin,     // carry-in
        output logic [N_DIGIT_OPERANDS*4+3:0]  S        // bcd sum
    );
    
      logic cout;
      logic bcd_cin  [N_DIGIT_OPERANDS-1:0];
      logic bcd_cout [N_DIGIT_OPERANDS-1:0];
    
      assign bcd_cin[0] = cin;
      assign cout = bcd_cout[N_DIGIT_OPERANDS-1];
    
      genvar i;
      generate
        for (i = 0; i < N_DIGIT_OPERANDS; i=i+1) begin
          bcd_adder i_bcd_adder(.A(A[(i+1)*4-1 : i*4]), .B(B[(i+1)*4-1 : i*4]), .S(S[(i+1)*4-1 : i*4]), .cin(bcd_cin[i]), .cout(bcd_cout[i]));
           
          if(i > 0) begin
            assign bcd_cin[i] = bcd_cout[i-1];
          end
        
        end
      endgenerate
    
      assign S[N_DIGIT_OPERANDS*4+3:N_DIGIT_OPERANDS*4] = cout ? 4'b1 : 4'b0;
      
endmodule