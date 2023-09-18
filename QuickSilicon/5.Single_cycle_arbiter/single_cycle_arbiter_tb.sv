`timescale 1ns/1ns

module single_cycle_arbiter_tb ();

  localparam N = 32;

  logic          clk;
  logic          reset;
  logic [N-1:0]  req_i;
  logic [N-1:0]  gnt_o;

  logic [N-1:0]  gnt_expected = 'b1;

single_cycle_arbiter 
#(.N(N))
i_single_cycle_arbiter
(
    .clk(clk),
    .reset(reset),
    .req_i(req_i),
    .gnt_o(gnt_o)
);


initial begin
    clk = '0;
    forever #5 clk = ~clk;
end

initial begin
     // Reset
        reset <= 1'b1; 
        repeat (3) @(posedge clk);
        reset <= 1'b0;

    for (int i = 0; i < 50; i = i + 1) begin
        req_i = $urandom();
        for (int b = 0; b < N; b = b + 1) begin
            if(req_i[b] == 1'b1) begin
                gnt_expected = gnt_expected << b;
                break;
            end
        end 
        #1
        if(gnt_o != gnt_expected) begin
            $display("\nFAIL! iter = %1d  Expected gnt_o = %1d  Reality gnt_o = %1d", i, gnt_expected, gnt_o);
            $finish;
        end
        gnt_expected = 'b1;
        @(posedge clk);
    end
    $display("\nTEST PASS!");
    $finish;
end

endmodule