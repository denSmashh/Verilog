module ps2_ctrl
(
   // System
   input  logic        clk,  
   input  logic        rstn,
   
   // PS2 Interface
   inout  				  ps2_clk,
   inout  				  ps2_data,
   
	// Error signal 
	output logic 		  tx_error,
	output logic 		  middle_button,
	output logic 		  right_button,
	output logic 		  left_button,
	output logic 		  init_done_o,
	
   // Rx PS2 mouse coordinates
   output logic        rx_vld,
	output logic [2:0]  pkt_cnt_o,
   output logic [7:0]  rx_x_coord,
   output logic [7:0]  rx_y_coord
);

//--------------------------------------------- Struct & Wires & Regs -----------------------------------------//
logic       ps2_clk_sync;
logic       ps2_data_sync;
logic       ps2_clk_sync_prev;
logic       ps2_clk_sync_negedge;
logic       ps2_clk_sync_posedge;

logic       init_done;
logic       start_bit_rx;

logic       rx_valid;
logic [7:0] rx_payload;

logic [7:0] tx_payload;
logic			tx_req;
//logic 		tx_ack;
logic 		rx_ack;
logic 		tx_ack_wait;
logic			tx_valid;

logic       tx_ps2_clk_o;
logic       tx_ps2_clk_oe;
logic       tx_ps2_data_o;
logic       tx_ps2_data_oe;

logic [63:0] idle_counter;

logic [2:0] pkt_cnt;

typedef struct packed {
	logic y_ovf;
	logic x_ovf;
	logic y_sign;
	logic x_sign;
	logic vdd;
	logic middle_button;
	logic right_button;
	logic left_button; 		
} ps2_pkt_byte1_t;


typedef struct packed {	
	logic [7:0] y_coord;
	logic [7:0] x_coord;
	ps2_pkt_byte1_t byte1;
} ps2_pkt_t;

ps2_pkt_t rx_pkt;


//---------------------------------------------- PS2 sync & detect -------------------------------------------//
// synchronize ps2 inputs
always_ff @(posedge clk, negedge rstn) begin
   if (~rstn) begin
      ps2_clk_sync  <= 1'b1;
      ps2_data_sync <= 1'b1;
   end
   else begin 
      ps2_clk_sync  <= ps2_clk;
      ps2_data_sync <= ps2_data;
   end
end

// detect negative & positive edge ps2_clk signal
always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) ps2_clk_sync_prev <= 1'b1;
    else ps2_clk_sync_prev <= ps2_clk_sync;
end

assign ps2_clk_sync_negedge =   ps2_clk_sync_prev  & (~ps2_clk_sync);
assign ps2_clk_sync_posedge = (~ps2_clk_sync_prev) &   ps2_clk_sync;

// detect rx start bit
assign start_bit_rx = ps2_clk_sync_negedge & (~ps2_data_sync);


//----------------------------------------- State machine PS2 Controller ---------------------------------------//
typedef enum logic [2:0] { PS2_IDLE,
                           PS2_RX,
                           PS2_TX,
                           PS2_TX_ACK,
                           PS2_DELAY   } ctrl_state_t;
ctrl_state_t ctrl_state;
ctrl_state_t ctrl_next_state;

always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) ctrl_state <= PS2_IDLE;
    else ctrl_state <= ctrl_next_state;
end         

always_comb begin
   case (ctrl_state)
      PS2_IDLE: begin
         if      (~init_done && idle_counter == 64'hFFFFFFFFFFFFFFFF)    ctrl_next_state = PS2_TX;  // fix ~init_done
         else if (start_bit_rx)  ctrl_next_state = PS2_RX;
         else                    ctrl_next_state = PS2_IDLE;
      end
      
      PS2_RX: begin
			if (rx_valid) ctrl_next_state = PS2_IDLE;
			else 			  ctrl_next_state = PS2_RX; 
      end
      
      PS2_TX: begin
			if (tx_ack_wait) ctrl_next_state = PS2_TX_ACK;
			else 				  ctrl_next_state = PS2_TX;
      end
      
      PS2_TX_ACK: begin
			if (ps2_clk_sync_posedge && (~ps2_data_sync)) ctrl_next_state = PS2_IDLE;
			else 														 ctrl_next_state = PS2_TX_ACK;
      end
      
//      PS2_DELAY: begin
//      
//      end
      
      default: begin
			ctrl_next_state = PS2_IDLE;
		end
	endcase
end


//------------------------------------------- PS2 Receiver ------------------------------------------//
ps2_rx i_ps2_rx 
(
   .clk(clk),
   .rstn(rstn),
   .ps2_clk(ps2_clk_sync),
   .ps2_data(ps2_data_sync),
   .ps2_clk_negedge(ps2_clk_sync_negedge),
   .ps2_clk_posedge(ps2_clk_sync_posedge),
   .rx_start_bit(start_bit_rx),
   //.tx_ack(tx_ack),
   .rx_valid(rx_valid),
   .rx_payload(rx_payload)
);


//------------------------------------------- PS2 Transmitter ---------------------------------------//
ps2_tx i_ps2_tx
(
   .clk(clk),
   .rstn(rstn),
	.ps2_clk_negedge(ps2_clk_sync_negedge),
   .ps2_clk_posedge(ps2_clk_sync_posedge),
	.rx_ack(rx_ack),
	.tx_payload(tx_payload),
	.tx_req(tx_req),
	.tx_valid(tx_valid),
	.tx_ack_wait(tx_ack_wait),
	.tx_error(tx_error),
	.ps2_clk_o(tx_ps2_clk_o),
   .ps2_clk_oe(tx_ps2_clk_oe),
	.ps2_data_o(tx_ps2_data_o),
	.ps2_data_oe(tx_ps2_data_oe)
);


//----------------------------------------- Tristate Buffers PS2 ------------------------------------//
assign ps2_clk  = (tx_ps2_clk_oe)  ? tx_ps2_clk_o  : 1'bz;
assign ps2_data = (tx_ps2_data_oe) ? tx_ps2_data_o : 1'bz;


//-------------------------------------- Rx & Tx Control signals ------------------------------------//
always_ff @(posedge clk, negedge rstn) begin
   if (~rstn) init_done <= 1'b0;
   else if (tx_valid) init_done <= 1'b1;
end

always_ff @(posedge clk, negedge rstn) begin
   if (~rstn) tx_payload <= 8'h0;
   else if (~init_done) tx_payload <= 8'hf4;
	else tx_payload <= 8'h00;
end

always_ff @(posedge clk, negedge rstn) begin
   if (~rstn) tx_req <= 1'b0;
   else if (ctrl_next_state == PS2_TX) tx_req <= 1'b1;
	else tx_req <= 1'b0;
end

always_ff @(posedge clk, negedge rstn) begin
   if (~rstn) rx_ack <= 1'b0;
   else if (ctrl_next_state == PS2_IDLE && ctrl_state == PS2_TX_ACK) rx_ack <= 1'b1;
	else rx_ack <= 1'b0;
end

always @(posedge clk, negedge rstn) begin
	if (~rstn) idle_counter <= 64'h0;
	else if ((ctrl_state == PS2_IDLE) && (idle_counter != 64'hFFFFFFFFFFFFFFFF)) idle_counter <= idle_counter + 64'h1;
	else if (ctrl_state != PS2_IDLE) idle_counter <= 64'h0;
end

//assign tx_req = (ctrl_next_state == PS2_TX);
//assign tx_ack = (ctrl_next_state == PS2_TX_ACK);


//----------------------------------------- Packet Proccessing --------------------------------------/
always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) pkt_cnt <= 3'h0;
    else if (pkt_cnt == 3'h3) pkt_cnt <= 3'h0;
    else if (rx_valid) pkt_cnt <= pkt_cnt + 3'h1;
end

always_ff @(posedge clk, negedge rstn) begin
   if (~rstn) rx_pkt <= 24'b0;
	else if (rx_valid) begin
		if (pkt_cnt == 3'h0) begin
			rx_pkt.byte1 <= rx_payload;
		end

//		else if (pkt_cnt == 3'h1) begin 
//			if (rx_pkt.byte1.x_sign) rx_pkt.x_coord <= rx_pkt.x_coord - (rx_payload >> 5);
//			else rx_pkt.x_coord <= rx_pkt.x_coord + (rx_payload >> 5);
//		end
//		
//		else if (pkt_cnt == 3'h2) begin
//			if (rx_pkt.byte1.y_sign) rx_pkt.y_coord <= rx_pkt.y_coord - (rx_payload >> 5);
//			else rx_pkt.y_coord <= rx_pkt.y_coord + (rx_payload >> 5);
//		end		
		else if (pkt_cnt == 3'h1) begin 
			if (rx_pkt.byte1.x_sign) rx_pkt.x_coord <= rx_pkt.x_coord - ((rx_payload >> 2) / 4'd10);
			else rx_pkt.x_coord <= rx_pkt.x_coord + ((rx_payload >> 2) / 4'd10);
		end
		
		else if (pkt_cnt == 3'h2) begin
			if (rx_pkt.byte1.y_sign) rx_pkt.y_coord <= rx_pkt.y_coord - ((rx_payload >> 2) / 4'd10);
			else rx_pkt.y_coord <= rx_pkt.y_coord + ((rx_payload >> 2) / 4'd10);
		end
	end
end

assign rx_vld = rx_valid;
assign pkt_cnt_o = pkt_cnt;

assign middle_button = rx_pkt.byte1.middle_button;
assign right_button = rx_pkt.byte1.right_button;
assign left_button = rx_pkt.byte1.left_button;

assign rx_x_coord = rx_pkt.x_coord;
assign rx_y_coord = rx_pkt.y_coord;

assign init_done_o = init_done;

endmodule
