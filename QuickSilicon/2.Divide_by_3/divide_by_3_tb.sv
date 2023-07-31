`timescale 1ns/1ns

module divide_by_3_tb ();

logic clk;
logic reset;
logic x_i;
logic div_o;

logic [255:0] value;
logic div_val;

divide_by_3 i_divide_by_3 (
    .clk(clk),
    .reset(reset),
    .x_i(x_i),
    .div_o(div_o)
);

initial begin
    clk = '0;
    forever #5 clk = ~clk;
end

initial begin
    
    // Reset
    value <= '0;
    reset <= 1'b1;
    repeat (3) @(posedge clk);
    reset <= 1'b0;
    
    @(posedge clk);
    
    // Random test
    for (int i = 0; i < 100; i = i + 1) begin   
       x_i = $urandom_range(0,1);    
       #1
       value = {value[254:0],x_i};
       if(value % 3 == 0) div_val = 1;
       else               div_val = 0;
        
        if(div_o != div_val) begin
            $display("FAIL! Error in number %d", value);
            $finish;
        end
        
       repeat (1) @ (posedge clk);
    end
    
$display("TEST PASS!");
$finish;
end


endmodule
