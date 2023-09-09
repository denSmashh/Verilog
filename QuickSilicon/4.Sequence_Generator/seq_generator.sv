module seq_generator (
    input   logic           clk,
    input   logic           reset,
    output  logic [31:0]    seq_o
);

logic [2:0] [31:0] seq_shift_reg;
logic [31:0] new_seq_o;

always_ff @(posedge clk or posedge reset) begin : SHIFT_REGS
    if (reset) seq_shift_reg <= {32'b0, 32'b0, 32'b1};
    else seq_shift_reg <= {seq_shift_reg[1], seq_shift_reg[0], new_seq_o};
end : SHIFT_REGS

assign new_seq_o = seq_shift_reg[1] + seq_shift_reg[2];
    
assign seq_o = new_seq_o;

endmodule