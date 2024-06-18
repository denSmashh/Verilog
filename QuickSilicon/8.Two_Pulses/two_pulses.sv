module two_pulses (
  input   logic       clk,
  input   logic       reset,

  input   logic       x_i,
  input   logic       y_i,

  output  logic       p_o
);

logic x_init;
logic p_comb, p_prev;
logic [1:0] cnt_state, cnt_next_state;
  
localparam logic [1:0] CNT_EQUAL_0 = 2'b00;
localparam logic [1:0] CNT_EQUAL_1 = 2'b01;
localparam logic [1:0] CNT_EQUAL_2 = 2'b10;
localparam logic [1:0] CNT_OVER_2  = 2'b11;



always_ff @(posedge clk or posedge reset) begin
    if (reset) cnt_state <= CNT_EQUAL_0;
    else cnt_state <= cnt_next_state;
end

always_comb begin
    cnt_next_state = cnt_state;
    if (x_i) cnt_next_state = {1'b0, y_i};
    else if (y_i) begin
        case (cnt_state)
            CNT_EQUAL_0,
            CNT_EQUAL_1,
            CNT_EQUAL_2: cnt_next_state = cnt_state + 2'b01;
            CNT_OVER_2 : cnt_next_state = cnt_state;
            default    : cnt_next_state = CNT_EQUAL_0;
        endcase
    end
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) p_prev <= 1'b0;
    else p_prev <= p_comb;
end
  
always_ff @(posedge clk or posedge reset) begin
    if (reset) x_init <= 1'b0;
    else if (x_i) x_init <= 1'b1;
end

assign p_comb = (p_prev == 1'b0 && x_i && cnt_state == CNT_EQUAL_2 && x_init) ? 1'b1 :
                (p_prev == 1'b1 && ~y_i)                                      ? 1'b1 : 1'b0;

assign p_o = p_comb;

endmodule
