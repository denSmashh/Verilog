`timescale 1ns/1ns

module seq_generator_tb ();

logic           clk;
logic           reset;
logic [31:0]    seq_o;

int unsigned seq[3]; 

int unsigned expected_val;

seq_generator i_seq_generator
(
    .clk(clk),
    .reset(reset),
    .seq_o(seq_o)
);


initial begin
    clk = '0;
    forever #5 clk = ~clk;
end


initial begin
    
    for(int j = 0; j < 3; j = j + 1) begin      
        // Reset
        reset <= 1'b1;
        seq = {0,0,1}; 
        repeat (3) @(posedge clk);
        reset <= 1'b0;

        // Sequence test
        for (int i = 0; i < 50; i = i + 1) begin
            expected_val = seq[0] + seq[1];  
            #1
            if(expected_val != seq_o) begin
                $display("\nFAIL! iter = %1d  Expected seq_o = %1d  Reality seq_o = %1d", i, expected_val, seq_o);
                $finish;
            end

            seq[0] = seq[1];
            seq[1] = seq[2];
            seq[2] = expected_val;

            $write("%1d ",expected_val);

            @(posedge clk);
        end
        $display();
    end

    $display("\nTEST PASS!");
    $finish;
end

endmodule