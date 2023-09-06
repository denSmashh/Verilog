`timescale 1ns/1ns

module palindrome3b_tb ();

logic clk;
logic reset;
logic x_i;
logic palindrome_o;

logic [1:0] value;
logic value_is_palindrome;

integer i;

palindrome3b i_palindrome3b (
    .clk(clk),
    .reset(reset),
    .x_i(x_i),
    .palindrome_o(palindrome_o)
);

initial begin
    clk = '0;
    forever #5 clk = ~clk;
end


initial begin
    
    // Reset
    value <= '0;
    reset <= 1'b1;
    repeat (2) @(posedge clk);
    reset <= 1'b0;
    
    
    // Random test
    for (i = 0; i < 100; i = i + 1) begin   
        x_i = $urandom_range(0,1);    
        value = {value[0],x_i};
        if(i > 1 && value[1] == x_i) value_is_palindrome = 1;
        else value_is_palindrome = 0;       
        #1
        if(palindrome_o != value_is_palindrome) begin
            $display("iteration = %1d:  FAIL! Error in value %b", i, value);
            $finish;
        end
        @ (posedge clk);
    end
    
$display("TEST PASS!");
$finish;
end

endmodule
