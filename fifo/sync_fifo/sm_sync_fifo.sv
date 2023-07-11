// simple synchronous FIFO
// code from lesson 10 digital defign school
// code contain one problem with read data with 'active' empty signal

`define READ_FIFO_COMB_OUT
//`define READ_FIFO_REG_OUT

module sm_sync_fifo 
#(
    parameter DW = 32,
    parameter FIFO_DEPTH = 16
)
(
    input  logic             clk,
    input  logic             rstn,
    input  logic             wr_en,
    input  logic             rd_en,
    input  logic [DW-1:0]    data_in,
    output logic [DW-1:0]    data_out,
    output logic             empty,
    output logic             full
);
    
localparam AW = $clog2(FIFO_DEPTH); 

logic [DW-1:0] ram_fifo [0:FIFO_DEPTH-1];

logic [AW-1:0] write_ptr;   
logic [AW-1:0] read_ptr;
logic [AW:0] status_counter;


always_ff @(posedge clk) begin : WRITE_FIFO
    if(~rstn) write_ptr <= 0;
    else if (wr_en) begin
        ram_fifo[write_ptr] <= data_in;
        //write_ptr <= write_ptr + 1;
        write_ptr <= (write_ptr == FIFO_DEPTH-1) ? 'b0 : write_ptr + 1;
    end
end


`ifdef READ_FIFO_REG_OUT
    always_ff @(posedge clk) begin : READ_FIFO_REG_OUT
        if(~rstn) read_ptr <= 0;
        else if (rd_en) begin
            data_out <= ram_fifo[read_ptr];
            //read_ptr <= read_ptr + 1;
            read_ptr <= (read_ptr == FIFO_DEPTH-1) ? 'b0 : read_ptr + 1;
        end
    end


`elsif READ_FIFO_COMB_OUT 
    always_ff @(posedge clk) begin : READ_FIFO_COMB_OUT
        if(~rstn) read_ptr <= 0;
        else if (rd_en) begin
            //read_ptr <= read_ptr + 1;
            read_ptr <= (read_ptr == FIFO_DEPTH-1) ? 'b0 : read_ptr + 1;
        end
    end

    assign data_out = ram_fifo[read_ptr];

`endif  


always_ff @(posedge clk) begin : FIFO_CTRL
    if(~rstn) status_counter <= 0;
    else if (wr_en && !rd_en)
        status_counter <= status_counter + 1;
    else if (!wr_en && rd_en)
        status_counter <= status_counter - 1;
end


// fifo control signals
assign empty = (status_counter == 'b0);             
assign full = (status_counter == FIFO_DEPTH);

endmodule
