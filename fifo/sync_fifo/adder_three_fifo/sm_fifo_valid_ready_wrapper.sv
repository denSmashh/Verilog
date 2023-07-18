module sm_fifo_valid_ready_wrapper 
#(
    parameter DW = 32,
    parameter FIFO_DEPTH = 16
)
(
    input  logic             clk,
    input  logic             rstn,
    output logic             valid_m,   // master fifo signals
    input  logic             ready_m,
    input  logic             valid_s,   // slave fifo signals
    output logic             ready_s,
    input  logic [DW-1:0]    data_in,
    output logic [DW-1:0]    data_out
);
    
logic fifo_empty;    
logic fifo_full;
logic fifo_wr_en;
logic fifo_rd_en;

assign valid_m = ~fifo_empty;
assign ready_s = ~fifo_full;

assign fifo_wr_en = valid_s & ready_s;
assign fifo_rd_en = valid_m & ready_m;


sm_sync_fifo 
#(
    .DW(DW),
    .FIFO_DEPTH(FIFO_DEPTH)
 )
 sync_fifo_master
 (
    .clk(clk),
    .rstn(rstn),
    .wr_en(fifo_wr_en),
    .rd_en(fifo_rd_en),
    .data_in(data_in),
    .data_out(data_out),
    .empty(fifo_empty),
    .full(fifo_full)
 );


endmodule