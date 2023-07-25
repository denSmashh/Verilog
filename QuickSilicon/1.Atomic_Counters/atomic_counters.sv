module atomic_counters (
  input  logic          clk,
  input  logic          reset,
  input  logic          trig_i,
  input  logic          req_i,
  input  logic          atomic_i,
  output logic          ack_o,
  output logic[31:0]    count_o
);

  logic [63:0] count_q;
  logic [31:0] count_q_high;
  logic atomic_ff;
  logic req_ff;

 always_ff @(posedge clk or posedge reset) begin : COUNTER
     if(reset) count_q <= 64'h0;
     else if (trig_i) count_q <= count_q + 64'h1;
 end

always_ff @(posedge clk or posedge reset) begin : COUNTER_MSB_REG
    if (reset) count_q_high <= 32'b0;
    else if (atomic_i) count_q_high <= count_q[63:32];
end     

always_ff @(posedge clk or posedge reset) begin : REQ_REG
    if (reset) req_ff <= 1'b0;
    else req_ff <= req_i;
end

always_ff @(posedge clk or posedge reset) begin : ATOMIC_REG
    if (reset) atomic_ff <= 1'b0;
    else atomic_ff <= atomic_i;
end


always_comb begin : COUNT_O_LOGIC
  if(req_ff) begin
    if(atomic_ff) count_o = count_q[31:0];
    else count_o = count_q_high;
  end
  else begin
    count_o = 32'h0;
  end
end

assign ack_o = req_ff;

endmodule
