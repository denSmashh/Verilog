`timescale 1ns/1ns

module atomic_counters_tb ();

  logic         clk;
  logic         reset;
  logic         trig_i;
  logic         req_i;
  logic         atomic_i;
  logic         ack_o;
  logic [31:0]  count_o;
    
  logic [63:0]  cnt;

atomic_counters dut (
  .clk(clk),
  .reset(reset),
  .trig_i(trig_i),
  .req_i(req_i),
  .atomic_i(atomic_i),
  .ack_o(ack_o),
  .count_o(count_o)
);


task read_req();
    req_i <= 1'b1;
    atomic_i <= 1'b1;
    @(posedge clk);
    atomic_i <= 1'b0;
    #1
    if(count_o != cnt[31:0]) begin
        $display ("FAIL LSB: count_o - %h   expected - %h ", count_o[31:0], cnt[31:0]);
        $finish;
    end
    
    @(posedge clk);
    req_i <= 1'b0;
    #1
    if(count_o != cnt[63:32]) begin
        $display ("FAIL MSB: count_o - %h   expected - %h ", count_o[31:0], cnt[63:32]);
        $finish;
    end
endtask 


task event_trigger();
    trig_i <= 1'b1;
    @(posedge clk);
    trig_i <= 1'b0;
    cnt <= cnt + 1;
endtask 

task event_trigger_parallel();
    trig_i <= 1'b1;
    req_i <= 1'b1;
    
    @(posedge clk);
    atomic_i <= 1'b1;
    cnt <= cnt + 1;
    
    @(posedge clk);
    atomic_i <= 1'b0;
    cnt <= cnt + 1;
    #1
    if(count_o != cnt[31:0]) begin
        $display ("FAIL LSB: count_o - %h   expected - %h ", count_o[31:0], cnt[31:0]);
        $finish;
    end
    
    @(posedge clk);
    req_i <= 1'b0;
    cnt <= cnt + 1;
    #1
    if(count_o != cnt[63:32]) begin
        $display ("FAIL MSB: count_o - %h   expected - %h ", count_o[31:0], cnt[63:32]);
        $finish;
    end
        
    @(posedge clk);
    trig_i <= 1'b0;
    cnt <= cnt + 1;
    
endtask



initial begin
    clk = '0;
    forever #5 clk = ~ clk;
end
 
initial begin

    // Reset
    #3 reset <= '1;
    repeat (3) @ (posedge clk);
    reset <= '0;
    
    
    // test lsb bits 64-bit counter
    cnt <= '0;
    repeat (5) begin 
      event_trigger();
      event_trigger();
      @(posedge clk);
      read_req();
    end
    @(posedge clk);    
    event_trigger_parallel();

    repeat(3) @(posedge clk);    
    
    // test msb bits 64-bit counter
    cnt <= 64'hFFFFFFFD;
    force atomic_counters.count_q = 64'hFFFFFFFD;
    release atomic_counters.count_q;
    repeat (5) begin 
      event_trigger();
      event_trigger();
      read_req();
      @(posedge clk);
    end
    @(posedge clk);
    event_trigger_parallel();

    // Done
    $display ("PASS");
    $finish;  
end
    
endmodule