module three_fifo_tb;
  
  localparam DATA_WIDTH = 16;
  localparam FIFO_DEPTH = 16;

  logic        clk;
  logic        rstn;
  logic        can_push_a;
  logic        push_a;
  logic [DATA_WIDTH-1:0] a;
  logic        can_push_b;
  logic        push_b;
  logic [DATA_WIDTH-1:0] b;
  logic        can_pop_sum;
  logic        pop_sum;
  logic [DATA_WIDTH-1:0] sum;

  adder_three_fifo 
  #( 
    .DW(DATA_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH)
   )
   dut 
   (
    .clk(clk),
    .rstn(rstn),

    .a_data(a),
    .a_valid(push_a),
    .a_ready(can_push_a),

    .b_data(b),
    .b_valid(push_b),
    .b_ready(can_push_b),

    .s_data(sum),
    .s_valid(can_pop_sum),
    .s_ready(pop_sum)
  );  

  //--------------------------------------------------------------------------

  initial
  begin
    clk = '0;
    forever #5 clk = ~ clk;
  end
  
  //--------------------------------------------------------------------------

  bit back_to_back  = 1;
  bit back_pressure = 0;

  // Sender for a

  always @ (posedge clk)
  begin
     # 1 // This delay is necessary because of combinational logic after ff
         // for can_push_a

    if (~rstn)
    begin
      a      <= '0;
      push_a <= '0;
    end
    else if (can_push_a & (back_to_back | $urandom_range (1, 100) <= 50))
    begin
      push_a <= '1;
      a <= a + 16'h1;
    end
    else
    begin
      push_a <= '0;
    end
  end

  //--------------------------------------------------------------------------

  // Sender for b

  always @ (posedge clk)
  begin
     # 1 // This delay is necessary because of combinational logic after ff
         // for can_push_b

    if (~rstn)
    begin
      b      <= '0;
      push_b <= '0;
    end
    else if (  can_push_b
             & (back_to_back | $urandom_range (1, 100) <= 90)
             & ~ back_pressure)
    begin
      push_b <= '1;
      b <= b + 16'h100;
    end
    else
    begin
      push_b <= '0;
    end
  end

  //--------------------------------------------------------------------------

  // Receiver for sum - randomized pop signal

  reg pop_sum_raw;

  always @ (posedge clk)
    if (~rstn)
      pop_sum_raw <= '0;
    else
      pop_sum_raw <= back_to_back | ($urandom_range (1, 100) <= 50);

  assign pop_sum = pop_sum_raw & can_pop_sum;

  // Receiver for sum - the expected value

  logic [15:0] expected_sum;

  always @ (posedge clk)
    if (~rstn)
    begin
      expected_sum <= 16'h101;
    end
    else if (pop_sum)
    begin
      if (sum != expected_sum)
      begin
        $display ("FAIL: %h EXPECTED", expected_sum);
        $finish;
      end

      expected_sum <= expected_sum + 16'h101;
    end

  //--------------------------------------------------------------------------

  // Logger

  int cycle = 0;

  always @ (posedge clk)
  begin
    $write ("%4d ", cycle ++);

    if ( push_a  ) $write ( " a %h"   , a   ); else $write ( "       " );
    if ( push_b  ) $write ( " b %h"   , b   ); else $write ( "       " );
    if ( pop_sum ) $write ( " sum %h" , sum );
    $display;
  end

  //--------------------------------------------------------------------------

  initial
  begin

    repeat (2) @ (posedge clk);
    #3 rstn <= '0;
    repeat (2) @ (posedge clk);
    rstn <= '1;

    back_to_back = 1;
    repeat (10)  @ (posedge clk);

    back_pressure = 1;
    repeat (10)  @ (posedge clk);

    back_pressure = 0;
    back_to_back  = 0;

    repeat (100) @ (posedge clk);

    $display ("PASS");
    $finish;
  end

endmodule