`timescale 1ns/1ns

module events_to_apb ();

  logic         clk;
  logic         reset;
  logic         event_a_i;
  logic         event_b_i;
  logic         event_c_i;
  logic         apb_psel_o;
  logic         apb_penable_o;
  logic [31:0]  apb_paddr_o;
  logic         apb_pwrite_o;
  logic [31:0]  apb_pwdata_o; 
  logic         apb_pready_;

  logic [31:0]  expected_wdata_event_a;
  logic [31:0]  expected_wdata_event_b;
  logic [31:0]  expected_wdata_event_c;


events_to_apb i_events_to_apb
(
    .clk(clk),
    .reset(reset),
    .event_a_i(event_a_i),
    .event_b_i(event_b_i),
    .event_c_i(event_c_i),
    .apb_psel_o(apb_psel_o),
    .apb_penable_o(apb_penable_o),
    .apb_paddr_o(apb_paddr_o),
    .apb_pwrite_o(apb_pwrite_o),
    .apb_pwdata_o(apb_pwdata_o),
    .apb_pready_i(apb_pready_i)
);


initial begin
    clk = '0;
    forever #5 clk = ~clk;
end


task automatic apb_check(input logic req_event);
    @(posedge clk);
    if(apb_psel_o != 'b1) begin $display("\nError! apb_psel_o not asserted. Timestamp = %0t", $realtime); $finish; end
    
    @(posedge clk);
    if(apb_penable_o != 'b1) begin $display("\nError! apb_penable_o not asserted. Timestamp = %0t", $realtime); $finish; end    
    if(req_event == event_a_i && apb_paddr_o != 'hABBA00000)
        begin $display("\nError! Event A, apb_paddr_o incorrect. Timestamp = %0t", $realtime); $finish; end
    else if(req_event == event_b_i && apb_paddr_o != 'hBAFF0000)
        begin $display("\nError! Event B, apb_paddr_o incorrect. Timestamp = %0t", $realtime); $finish; end
    else if(req_event == event_c_i && apb_paddr_o != 'hCAFE0000)
        begin $display("\nError! Event C, apb_paddr_o incorrect. Timestamp = %0t", $realtime); $finish; end
    if(req_event == event_a_i && apb_pwdata_o != expected_wdata_event_a)
         begin $display("\nError! Event A, apb_wdata_o incorrect. Timestamp = %0t", $realtime); $finish; end
    else if(req_event == event_b_i && apb_pwdata_o != expected_wdata_event_b)
         begin $display("\nError! Event B, apb_wdata_o incorrect. Timestamp = %0t", $realtime); $finish; end
    else if(req_event == event_c_i && apb_pwdata_o != expected_wdata_event_c)
         begin $display("\nError! Event C, apb_wdata_o incorrect. Timestamp = %0t", $realtime); $finish; end
    @(posedge clk);


endtask 

initial begin
    // Reset
    reset <= 1'b1; 
    repeat (3) @(posedge clk);
    reset <= 1'b0;

    for (int i = 0; i < 10; i = i + 1) begin
        
    end

    $display("\nTEST PASS!");
    $finish;
end

endmodule