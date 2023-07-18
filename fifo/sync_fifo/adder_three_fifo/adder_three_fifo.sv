
// task from digital design school
// task: adding two numbers, numbers can come asynchronous 

module adder_three_fifo 
#(
    parameter DW = 32,
    parameter FIFO_DEPTH = 16
)
(
    input  logic            clk,
    input  logic            rstn,

    input  logic [DW-1:0]   a_data,
    input  logic            a_valid,
    output logic            a_ready,

    input  logic [DW-1:0]   b_data,
    input  logic            b_valid,
    output logic            b_ready,

    output logic [DW-1:0]   s_data,
    output logic            s_valid,
    input  logic            s_ready
);


logic [DW-1:0] data_a_fifo_out;
logic [DW-1:0] data_b_fifo_out;
logic [DW-1:0] data_sum_fifo_in;

logic a_valid_master;
logic b_valid_master;
logic a_ready_master;
logic b_ready_master;

logic adder_valid;
logic adder_ready; 


assign adder_valid = a_valid_master & b_valid_master;
assign a_ready_master = adder_ready & adder_valid;
assign b_ready_master = a_ready_master;

assign data_sum_fifo_in = data_a_fifo_out + data_b_fifo_out; 


sm_fifo_valid_ready_wrapper
#(  .DW(DW),
    .FIFO_DEPTH(FIFO_DEPTH)
 )
fifo_a
(
    .clk(clk),
    .rstn(rstn),
    .valid_m(a_valid_master), 
    .ready_m(a_ready_master),
    .valid_s(a_valid),   
    .ready_s(a_ready),
    .data_in(a_data),
    .data_out(data_a_fifo_out)
);
    


sm_fifo_valid_ready_wrapper
#(  .DW(DW),
    .FIFO_DEPTH(FIFO_DEPTH)
 )
fifo_b
(
    .clk(clk),
    .rstn(rstn),
    .valid_m(b_valid_master), 
    .ready_m(b_ready_master),
    .valid_s(b_valid),   
    .ready_s(b_ready),
    .data_in(b_data),
    .data_out(data_b_fifo_out)
);



sm_fifo_valid_ready_wrapper
#(  .DW(DW),
    .FIFO_DEPTH(FIFO_DEPTH)
 )
fifo_sum
(
    .clk(clk),
    .rstn(rstn),
    .valid_m(s_valid), 
    .ready_m(s_ready),
    .valid_s(adder_valid),
    .ready_s(adder_ready),
    .data_in(data_sum_fifo_in),
    .data_out(s_data)
);

    
endmodule
