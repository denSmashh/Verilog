`timescale 1ns/1ns

module ps2_top_tb ();

logic        sys_clk;    	
logic        sys_rstn;   	
wire         ps2_clk; 
wire         ps2_data;   
logic		 tx_error_led;	
logic [3:0]  sevseg_en;  	
logic [6:0]  sevseg;      	
reg          PS2_clock_r;
reg          PS2_data_r;

ps2_top ps2_top_dut
(
    .sys_clk(sys_clk),    	// Sys Clk  (50 MHz)
    .sys_rstn(sys_rstn),   	// Sys Rstn (Button on board)
    .ps2_clk(ps2_clk),    	// PS2 Sync
    .ps2_data(ps2_data),   	// PS2 Data
	.tx_error_led(tx_error_led),	//  Tx Error LED
    .sevseg_en(sevseg_en),  	// 7-segment LED enable section  (0 - on, 1 - off)
    .sevseg(sevseg)      	// 7-segment LED segment control (0 - on, 1 - off)
);

initial begin
    sys_clk = '0;
    forever #5 sys_clk = ~sys_clk;
end

initial
begin

  sys_rstn = 1'b0;
  repeat (3) @(posedge sys_clk);
  sys_rstn = 1'b1;

  #0 PS2_clock_r=1;
  #275 PS2_clock_r = 1; //s
  repeat( 22 ) 
  begin
    #25 PS2_clock_r=~PS2_clock_r;
  end
  #100 PS2_clock_r = 1;  
  repeat( 22 ) 
  begin
    #25 PS2_clock_r=~PS2_clock_r;
  end
  #300 PS2_clock_r = 1; 
  repeat( 22 ) 
  begin
    #25 PS2_clock_r=~PS2_clock_r;
  end
  #50 PS2_clock_r = 1; 
  repeat( 22 ) 
  begin
    #25 PS2_clock_r=~PS2_clock_r;
  end
end

initial
begin
    #250 PS2_data_r = 1; //s
    #50 PS2_data_r = 0; //start
    #50 PS2_data_r = 0; //0
    #50 PS2_data_r = 1; //1
    #50 PS2_data_r = 1; //2
    #50 PS2_data_r = 0; //3
    #50 PS2_data_r = 1; //4
    #50 PS2_data_r = 0; //5
    #50 PS2_data_r = 1; //6
    #50 PS2_data_r = 1; //7
    #50 PS2_data_r = 1; //parity bit
    #50 PS2_data_r = 0; //stop
    #50 PS2_data_r = 1; //s
    #50 PS2_data_r = 1; //s
    
    #50 PS2_data_r = 0; //start
    #50 PS2_data_r = 1; //0
    #50 PS2_data_r = 1; //1
    #50 PS2_data_r = 0; //2
    #50 PS2_data_r = 0; //3
    #50 PS2_data_r = 1; //4
    #50 PS2_data_r = 0; //5
    #50 PS2_data_r = 1; //6
    #50 PS2_data_r = 1; //7
    #50 PS2_data_r = 1; //parity bit
    #50 PS2_data_r = 0; //stop
    #50 PS2_data_r = 1; //s    
    #250 PS2_data_r = 1; //s

    #50 PS2_data_r = 0; //start
    #50 PS2_data_r = 0; //0
    #50 PS2_data_r = 1; //1
    #50 PS2_data_r = 1; //2
    #50 PS2_data_r = 1; //3
    #50 PS2_data_r = 1; //4
    #50 PS2_data_r = 1; //5
    #50 PS2_data_r = 1; //6
    #50 PS2_data_r = 1; //7
    #50 PS2_data_r = 1; //parity bit
    #50 PS2_data_r = 0; //stop
    #50 PS2_data_r = 1; //s

    #50 PS2_data_r = 0; //start
    #50 PS2_data_r = 0; //0
    #50 PS2_data_r = 1; //1
    #50 PS2_data_r = 1; //2
    #50 PS2_data_r = 0; //3
    #50 PS2_data_r = 1; //4
    #50 PS2_data_r = 0; //5
    #50 PS2_data_r = 1; //6
    #50 PS2_data_r = 1; //7
    #50 PS2_data_r = 1; //parity bit
    #50 PS2_data_r = 0; //stop
    #50 PS2_data_r = 1; //s
    #50 PS2_data_r = 1; //s
    #50 PS2_data_r = 1; //s
end

assign ps2_clk = PS2_clock_r;
assign ps2_data = PS2_data_r;

endmodule
