module low_power_channel 
(
  input   logic          clk,
  input   logic          reset,

  // Wakeup interface
  input   logic          if_wakeup_i,

  // Write interface
  input   logic          wr_valid_i,
  input   logic [7:0]    wr_payload_i,

  // Upstream flush interface
  output  logic          wr_flush_o,
  input   logic          wr_done_i,

  // Read interface
  input   logic          rd_valid_i,
  output  logic [7:0]    rd_payload_o,

  // Q-channel interface
  input   logic          qreqn_i,
  output  logic          qacceptn_o,
  output  logic          qactive_o
);

logic wr_flush_ff;
logic qacceptn_ff;
logic qactive_ff;
logic req_low_power;
logic fifo_empty;
logic fifo_full;
logic wr_valid_fifo;
logic [7:0] wr_payload_fifo;

qs_skid_buffer
#(
    .DATA_W(8)
) i_qs_skid_buffer 
(
    .clk(clk),
    .reset(reset),
    .i_valid_i(wr_valid_i),
    .i_data_i(wr_payload_i),
  	.i_ready_o(),
    .e_ready_i(~fifo_full),
    .e_valid_o(wr_valid_fifo),
    .e_data_o(wr_payload_fifo)
  );

qs_fifo
#(
    .DATA_W(8),
    .DEPTH(6)
) i_qs_fifo
(
    .clk(clk),
    .reset(reset),
    .push_i(wr_valid_fifo),
    .push_data_i(wr_payload_fifo),
    .pop_i(rd_valid_i),
    .pop_data_o(rd_payload_o),
    .empty_o(fifo_empty),
    .full_o(fifo_full)
);

//------------------------------------ Q-Channel FSM ----------------------------------//
typedef enum logic [1:0] {Q_RUN, Q_REQUEST, Q_STOPPED, Q_EXIT} state_t;

state_t state;
state_t next_state;

always_ff @(posedge clk or posedge reset) begin : TRANSITION_LOGIC_FSM
    if (reset) state <= Q_RUN;
    else state <= next_state;
end

always_comb begin : NEXT_STATE_LOGIC_FSM
    next_state = state;
    case (state)
        Q_RUN: begin
            if (~qreqn_i) next_state = Q_REQUEST;
        end
            
        Q_REQUEST: begin
            if (~qacceptn_ff) next_state = Q_STOPPED;
        end

        Q_STOPPED: begin
            if (qreqn_i) next_state = Q_EXIT;
        end
        
        Q_EXIT : begin
            if (qacceptn_ff) next_state = Q_RUN;
        end
    endcase 
end

assign req_low_power = wr_done_i & fifo_empty & (~qreqn_i);

always_ff @(posedge clk or posedge reset) begin : QACCEPTN_OUTPUT_LOGIC_FSM
    if (reset)
        qacceptn_ff <= 1'b1;
    else if (state == Q_REQUEST || state == Q_EXIT)
        qacceptn_ff <= (~req_low_power);
end

always_ff @(posedge clk or posedge reset) begin : QACTIVE_OUTPUT_LOGIC_FSM
    if (reset)
        qactive_ff <= 1'b0;
    else
        qactive_ff <= (~fifo_empty | rd_valid_i | wr_valid_i);
end

always_ff @(posedge clk or posedge reset) begin : WR_FLUSH_OUTPUT_LOGIC_FSM
    if (reset)
        wr_flush_ff <= 1'b0;
    else if (state == Q_REQUEST)
        wr_flush_ff <= 1'b1;
    else if (wr_done_i)
        wr_flush_ff <= 1'b0;
end

assign qactive_o  = if_wakeup_i | qactive_ff;
assign qacceptn_o = qacceptn_ff;
assign wr_flush_o = wr_flush_ff;

endmodule