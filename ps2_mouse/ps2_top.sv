module ps2_top 
(
    input  logic        sys_clk,    	// Sys Clk  (50 MHz)
    input  logic        sys_rstn,   	// Sys Rstn (Button on board)

    inout          		ps2_clk,    	// PS2 Sync
    inout          		ps2_data,   	// PS2 Data
    
	 output logic			tx_error_led,	//  Tx Error LED
	 output logic			sequence_error_led,
	 output logic			rx_vld,
	 output logic			middle_button,
	 output logic			left_button,
	 output logic			right_button,
	 
	 output logic			pkt_cnt_0,
	 output logic			pkt_cnt_1,
	 output logic			pkt_cnt_2,
	 
    output logic [3:0]  sevseg_en,  	// 7-segment LED enable section  (0 - on, 1 - off)
    output logic [6:0]  sevseg      	// 7-segment LED segment control (0 - on, 1 - off)
);

logic [6:0]    sevseg_1;
logic [6:0]    sevseg_2;
logic [6:0]    sevseg_3;
logic [6:0]    sevseg_4;

logic 			tx_error;
logic [7:0]  	x_coord;
logic [7:0]	   y_coord;

logic [3:0] 	bcd_ed_x;
logic [3:0] 	bcd_des_x;
logic [3:0] 	bcd_ed_y;
logic [3:0] 	bcd_des_y;

logic [3:0] 	bcd_ed_pkt_cnt;
logic [3:0] 	bcd_des_pkt_cnt;

logic 			tx_error_inv;
logic 			middle_button_inv;
logic 			right_button_inv;
logic 			left_button_inv;
logic				seq_error_inv;
logic 			rx_vld_inv;
logic [2:0]		pkt_cnt_o;

logic init_done_o_inv;

assign tx_error_led  = ~tx_error_inv;
assign middle_button = ~middle_button_inv;
assign left_button 	= ~left_button_inv;
assign right_button 	= ~right_button_inv;
assign sequence_error_led = ~seq_error_inv;
assign rx_vld = ~init_done_o_inv;

assign pkt_cnt_0 = ~pkt_cnt_o[0];
assign pkt_cnt_1 = ~pkt_cnt_o[1];
assign pkt_cnt_2 = ~pkt_cnt_o[2];

ps2_ctrl i_ps2_ctrl
(
   .clk(sys_clk),  
   .rstn(sys_rstn),
   .ps2_clk(ps2_clk),
   .ps2_data(ps2_data),
	.tx_error(tx_error_inv),
	.rx_vld(rx_vld_inv),
	.pkt_cnt_o(pkt_cnt_o),
	.init_done_o(init_done_o_inv),
	.middle_button(middle_button_inv),
	.right_button(right_button_inv),
	.left_button(left_button_inv),
   .rx_x_coord(x_coord),
   .rx_y_coord(y_coord)
);

bin2bcd i_bin2bcd_x
(
	.clk(sys_clk),
	.rstn(sys_rstn),
	.lfsr_in(x_coord),
	.bcd_ed(bcd_ed_x),
	.bcd_des(bcd_des_x)
);

bin2bcd i_bin2bcd_y
(
	.clk(sys_clk),
	.rstn(sys_rstn),
	.lfsr_in(y_coord),
	.bcd_ed(bcd_ed_y),
	.bcd_des(bcd_des_y)
);

sevseg_conv i_sevseg_conv
(
   .bcd_ed_x(bcd_ed_x),
   .bcd_des_x(bcd_des_x),
   .bcd_ed_y(bcd_ed_y),
   .bcd_des_y(bcd_des_y),
   .sevseg_ed_x(sevseg_1),
   .sevseg_des_x(sevseg_2),
   .sevseg_ed_y(sevseg_3),
   .sevseg_des_y(sevseg_4)
);

sevseg_dyn_ind i_sevseg_dyn_ind
(
   .clk(sys_clk),
   .rstn(sys_rstn),
   .sevseg_1(sevseg_1),
   .sevseg_2(sevseg_2),
   .sevseg_3(sevseg_3),
   .sevseg_4(sevseg_4),
   .sevseg_en(sevseg_en),
   .sevseg_out(sevseg)
);


endmodule
