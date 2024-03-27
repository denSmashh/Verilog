module sevseg_conv
(
   input  logic [3:0] bcd_ed_x,
   input  logic [3:0] bcd_des_x,
   input  logic [3:0] bcd_ed_y,
   input  logic [3:0] bcd_des_y,
   output logic [6:0] sevseg_ed_x,
   output logic [6:0] sevseg_des_x,
   output logic [6:0] sevseg_ed_y,
   output logic [6:0] sevseg_des_y
);

always_comb begin
   case (bcd_ed_x)
      4'd0: sevseg_ed_x = 7'b1000000;
      4'd1: sevseg_ed_x = 7'b1111001;
      4'd2: sevseg_ed_x = 7'b0100100;
      4'd3: sevseg_ed_x = 7'b0110000;
      4'd4: sevseg_ed_x = 7'b0011001;
      4'd5: sevseg_ed_x = 7'b0010010;
      4'd6: sevseg_ed_x = 7'b0000010;
      4'd7: sevseg_ed_x = 7'b1111000;
      4'd8: sevseg_ed_x = 7'b0000000;
      4'd9: sevseg_ed_x = 7'b0010000;
      default: sevseg_ed_x = 7'b1111111;
   endcase
end

always_comb begin
   case (bcd_des_x) 
      4'd0: sevseg_des_x = 7'b1000000;
      4'd1: sevseg_des_x = 7'b1111001;
      4'd2: sevseg_des_x = 7'b0100100;
      4'd3: sevseg_des_x = 7'b0110000;
      4'd4: sevseg_des_x = 7'b0011001;
      4'd5: sevseg_des_x = 7'b0010010;
      4'd6: sevseg_des_x = 7'b0000010;
      4'd7: sevseg_des_x = 7'b1111000;
      4'd8: sevseg_des_x = 7'b0000000;
      4'd9: sevseg_des_x = 7'b0010000;
      default: sevseg_des_x = 7'b1111111;
   endcase
end

always_comb begin
   case (bcd_ed_y) 
      4'd0: sevseg_ed_y = 7'b1000000;
      4'd1: sevseg_ed_y = 7'b1111001;
      4'd2: sevseg_ed_y = 7'b0100100;
      4'd3: sevseg_ed_y = 7'b0110000;
      4'd4: sevseg_ed_y = 7'b0011001;
      4'd5: sevseg_ed_y = 7'b0010010;
      4'd6: sevseg_ed_y = 7'b0000010;
      4'd7: sevseg_ed_y = 7'b1111000;
      4'd8: sevseg_ed_y = 7'b0000000;
      4'd9: sevseg_ed_y = 7'b0010000;
      default: sevseg_ed_y = 7'b1111111;
   endcase
end

always_comb begin
   case (bcd_des_y) 
      4'd0: sevseg_des_y = 7'b1000000;
      4'd1: sevseg_des_y = 7'b1111001;
      4'd2: sevseg_des_y = 7'b0100100;
      4'd3: sevseg_des_y = 7'b0110000;
      4'd4: sevseg_des_y = 7'b0011001;
      4'd5: sevseg_des_y = 7'b0010010;
      4'd6: sevseg_des_y = 7'b0000010;
      4'd7: sevseg_des_y = 7'b1111000;
      4'd8: sevseg_des_y = 7'b0000000;
      4'd9: sevseg_des_y = 7'b0010000;
      default: sevseg_des_y = 7'b1111111;
   endcase
end


endmodule
