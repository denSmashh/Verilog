
`timescale 1ns/1ns

 module progressive_tb();
 
  localparam fifo_width = 8, fifo_depth = 5;
  
  logic                    clk;
  logic                    rstn;
  logic                    push;
  logic                    pop;
  logic [fifo_width - 1:0] write_data;

  logic [fifo_width - 1:0] rtl_read_data;
  logic                    rtl_empty;
  logic                    rtl_full;


  //----------------------- RTL MODEL ---------------------------------------------------

 //`define READ_FIFO_COMB_OUT

  sm_sync_fifo 
  #(
        .DW(fifo_width),
        .FIFO_DEPTH(fifo_depth)
  )
  dut_sm_sync_fifo
  (
    .clk(clk),
    .rstn(rstn),
    .wr_en(push),
    .rd_en(pop),
    .data_in(write_data),
    .data_out(rtl_read_data),
    .empty(rtl_empty),
    .full(rtl_full)
  );


  //--------------------------------------------------------------------------

  initial
  begin
    clk = '0;
    forever #5 clk = ~ clk;
  end
  
//   always begin
//     #5;
//     clk = ~clk;
//   end
  
  //--------------------------------------------------------------------------

  // Logger
//  always @ (posedge clk)
//    if (rstn)
//    begin
//      if (push)
//        $display ("push %h", write_data);
//      else
//        $display ("       ");

//      if (pop)
//        $display ("  pop %h", rtl_read_data);
//      else
//        $display ("        ");

//      # 1  // This delay is necessary because of combinational logic after ff
      
//      $display ("  %5s %4s",
//        rtl_empty ? "empty" : "     ",
//        rtl_full  ? "full"  : "    ");

//      $display (" [");

//    end
  
  //--------------------------------------------------------------------------

  initial
  begin
    //$dumpfile ("dump.vcd");
    //$dumpvars;

    // Initialization

    push <= '0;
    pop  <= '0;

    // Reset

    #3 rstn <= '0;
    repeat (6) @ (posedge clk);
    rstn <= '1;
    
    // Randomized test

    repeat (100)
    begin
      @ (posedge clk);
      # 1  // This delay is necessary because of combinational logic after ff

      pop  <= '0;
      push <= '0;

      if (rtl_full & $urandom_range (1, 100) <= 40)
      begin
        pop  <= '1;
        push <= '1;

        write_data <= $urandom;
      end

      if (~ rtl_empty & $urandom_range (1, 100) <= 50)
        pop <= '1;
      
      if (~ rtl_full & $urandom_range (1, 100) <= 60)
      begin
        push <= '1;
        write_data <= $urandom;
      end
    end

    $display ("PASS");
    $finish;
  end

endmodule
