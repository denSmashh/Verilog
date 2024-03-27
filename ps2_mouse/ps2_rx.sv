module ps2_rx 
(
   input  logic         clk,
   input  logic         rstn,
   
   input  logic         ps2_clk,
   input  logic         ps2_data,
   
   input  logic         ps2_clk_negedge,
   input  logic         ps2_clk_posedge,
   input  logic         rx_start_bit,
   //input  logic         tx_ack,
   
   output logic         rx_valid,
   output logic [7:0]   rx_payload
);


//--------------------------------------------- Wires & Regs -----------------------------------------//
logic       rx_valid_ff;
logic [7:0] rx_payload_ff;
logic [2:0] payload_cnt;


//------------------------------------- State machine PS2 Receiever ----------------------------------//
typedef enum logic [2:0] { RX_IDLE,
                           RX_PAYLOAD,
                           RX_PARITY_BIT,
                           RX_STOP_BIT		} rx_state_t;
                           //RX_ACK_TX      

rx_state_t receiver_state;
rx_state_t receiver_next_state;

always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) receiver_state <= RX_IDLE;
    else receiver_state <= receiver_next_state;
end         

always_comb begin
   case (receiver_state)
      RX_IDLE: begin
         //if      (tx_ack 		 && (~rx_valid_ff)) receiver_next_state = RX_ACK_TX;
         if (rx_start_bit && (~rx_valid_ff)) receiver_next_state = RX_PAYLOAD;
         else                   		     receiver_next_state = RX_IDLE;
      end
      
      RX_PAYLOAD: begin
         if (payload_cnt == 3'h7 && ps2_clk_posedge) receiver_next_state = RX_PARITY_BIT;
         else                                        receiver_next_state = RX_PAYLOAD;
      end
      
      RX_PARITY_BIT: begin
         if (ps2_clk_posedge) receiver_next_state = RX_STOP_BIT;
         else                 receiver_next_state = RX_PARITY_BIT;
      end
      
      RX_STOP_BIT: begin
         if (ps2_clk_posedge) receiver_next_state = RX_IDLE;
         else                             receiver_next_state = RX_STOP_BIT;
      end
      
      //RX_ACK_TX: begin
      //   if (ps2_clk_posedge && (~ps2_data)) receiver_next_state = RX_IDLE;
      //   else                                receiver_next_state = RX_ACK_TX;
      //end
      
      default: begin
         receiver_next_state = RX_IDLE;
      end
   endcase
end
   

//------------------------------------------ Control signals ----------------------------------------//
always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) payload_cnt <= 3'h0;
    else if (receiver_state != RX_PAYLOAD) payload_cnt <= 3'h0;
    else if (receiver_state == RX_PAYLOAD && ps2_clk_posedge) payload_cnt <= payload_cnt + 3'h1;
end

always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) rx_payload_ff <= 8'h00;
    else if (receiver_state == RX_PAYLOAD && ps2_clk_posedge) rx_payload_ff <= {ps2_data, rx_payload_ff[7:1]};
end

always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) rx_valid_ff <= 1'b0;
    else if (receiver_state == RX_STOP_BIT && ps2_clk_posedge) rx_valid_ff <= 1'b1;
    else rx_valid_ff <= 1'b0;
end

assign rx_valid = rx_valid_ff; 
assign rx_payload = rx_payload_ff;

endmodule
