module palindrome3b (
    input   logic        clk,
    input   logic        reset,
    input   logic        x_i,
    output  logic        palindrome_o
);

logic [1:0] dead_zone_cnt;
logic [1:0] prev_x_i;

always_ff @(posedge clk or posedge reset) begin : DEAD_ZONE_CNT
    if (reset) dead_zone_cnt <= 'b0;
    else if (dead_zone_cnt < 'd2) dead_zone_cnt <= dead_zone_cnt + 1;
end

always_ff @(posedge clk or posedge reset) begin : SHIFT_REGISTER
    if(reset) prev_x_i <= 'b0;
    else prev_x_i <= {prev_x_i[0], x_i};
end

always_comb begin
    if(dead_zone_cnt == 'd2 && prev_x_i[1] == x_i) begin
        palindrome_o <= 1'b1;
    end
    else begin
        palindrome_o <= 1'b0;
    end
end

endmodule
