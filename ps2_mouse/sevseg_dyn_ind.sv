module sevseg_dyn_ind
(
   input  logic       clk,
   input  logic       rstn,
   
   input  logic [6:0] sevseg_1,
   input  logic [6:0] sevseg_2,
   input  logic [6:0] sevseg_3,
   input  logic [6:0] sevseg_4,
   
   output logic [3:0] sevseg_en,
   output logic [6:0] sevseg_out
);

logic [3:0]  sel_digit;
logic [6:0]  sevseg_led;
logic [31:0] delay_cnt;

localparam SWITCH_DELAY = 32'd50000;

always @(posedge clk or negedge rstn) begin
   if(~rstn) delay_cnt <= 32'b0;
   else if (delay_cnt == SWITCH_DELAY ) delay_cnt <= 32'b0;
   else delay_cnt <= delay_cnt + 32'b1; 
end

always @(posedge clk or negedge rstn) begin
   if(~rstn) sel_digit <= 4'b1110;
   else if (delay_cnt == SWITCH_DELAY) sel_digit <= {sel_digit[2:0],sel_digit[3]};
end

always @(posedge clk or negedge rstn) begin
   if(~rstn) sevseg_led <= 7'b1111111;
   else begin
      sevseg_led <= (sel_digit == 4'b1110) ? sevseg_1 : 
                    (sel_digit == 4'b1101) ? sevseg_2 :
                    (sel_digit == 4'b1011) ? sevseg_3 :
                    (sel_digit == 4'b0111) ? sevseg_4 : 7'b1111111;
   end
end

assign sevseg_en  = sel_digit;
assign sevseg_out = sevseg_led;

endmodule
