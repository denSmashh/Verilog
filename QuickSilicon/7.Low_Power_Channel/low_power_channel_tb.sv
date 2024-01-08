`timescale 1ns/1ns

module low_power_channel_tb ();

logic          clk;
logic          reset;
logic          if_wakeup_i;
logic          wr_valid_i;
logic [7:0]    wr_payload_i;
logic          wr_flush_o;
logic          wr_done_i;
logic          rd_valid_i;
logic [7:0]    rd_payload_o;
logic          qreqn_i;
logic          qacceptn_o;
logic          qactive_o;

low_power_channel low_power_channel_dut
(
    .clk(clk),
    .reset(reset),
    .if_wakeup_i(if_wakeup_i),
    .wr_valid_i(wr_valid_i),
    .wr_payload_i(wr_payload_i),
    .wr_flush_o(wr_flush_o),
    .wr_done_i(wr_done_i),
    .rd_valid_i(rd_valid_i),
    .rd_payload_o(rd_payload_o),
    .qreqn_i(qreqn_i),
    .qacceptn_o(qacceptn_o),
    .qactive_o(qactive_o)
);

endmodule