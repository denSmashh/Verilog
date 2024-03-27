module ps2_tx
(
   input  logic         clk,
   input  logic         rstn,
		
	input  logic         ps2_clk_negedge,
   input  logic         ps2_clk_posedge,
	
	input  logic  			rx_ack,
	input  logic  			tx_req,
	input  logic [7:0] 	tx_payload,
	output logic 			tx_valid,
	output logic 			tx_error,
	output logic  			tx_ack_wait,
	
	output logic         ps2_clk_o,
   output logic         ps2_clk_oe,
	output logic         ps2_data_o,
	output logic         ps2_data_oe
);

//---------------------------------------------- PS2 DELAYS --------------------------------------------//

// Initiating Host-to-Device communication (for 50 MHz Clock)
localparam CLOCK_CYCLES_FOR_101US		= 5050;
localparam NUMBER_OF_BITS_FOR_101US	   = 13;
localparam COUNTER_INCREMENT_FOR_101US	= 13'h0001;

// Start of transmission error (for 50 MHz Clock)
localparam CLOCK_CYCLES_FOR_15MS		   = 750000;
localparam NUMBER_OF_BITS_FOR_15MS		= 20;
localparam COUNTER_INCREMENT_FOR_15MS	= 20'h00001;

// Sending data error (for 50 MHz Clock)
localparam CLOCK_CYCLES_FOR_2MS			= 100000;
localparam NUMBER_OF_BITS_FOR_2MS		= 17;
localparam	COUNTER_INCREMENT_FOR_2MS	= 17'h00001;


//--------------------------------------------- Wires & Regs --------------------------------------------//
logic [NUMBER_OF_BITS_FOR_101US-1:0] command_initiate_cnt;
logic [NUMBER_OF_BITS_FOR_15MS-1:0]	 tx_error_cnt;
logic [NUMBER_OF_BITS_FOR_2MS-1:0]	 transfer_counter;

logic [3:0] 	payload_cnt;
logic [8:0] 	tx_payload_shift_reg;

logic         	ps2_clk_o_next;
logic         	ps2_clk_oe_next;
logic         	ps2_data_o_next;
logic				ps2_data_oe_next;


//------------------------------------- State machine PS2 Transmitter ----------------------------------//
typedef enum logic [2:0] { TX_IDLE,
                           TX_INIT_DELAY,
                           TX_START_BIT,
                           TX_PAYLOAD,
									TX_STOP_BIT,
                           TX_WAIT_ACK,
									TX_ERROR			} tx_state_t;

tx_state_t transmitter_state;
tx_state_t transmitter_next_state;

always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) transmitter_state <= TX_IDLE;
    else transmitter_state <= transmitter_next_state;
end    

always_comb begin
   case (transmitter_state)
      TX_IDLE: begin
			if (tx_req) transmitter_next_state = TX_INIT_DELAY;
			else 			transmitter_next_state = TX_IDLE;
      end
      
		TX_INIT_DELAY: begin
			if (command_initiate_cnt == CLOCK_CYCLES_FOR_101US) transmitter_next_state = TX_START_BIT;
			else 																 transmitter_next_state = TX_INIT_DELAY;
		end
		
		TX_START_BIT: begin
			if 	  (ps2_clk_negedge) 								transmitter_next_state = TX_PAYLOAD;
			else if (tx_error_cnt == CLOCK_CYCLES_FOR_15MS) transmitter_next_state = TX_ERROR;
			else 															transmitter_next_state = TX_START_BIT;
		end
		
		TX_PAYLOAD: begin
			if (payload_cnt == 4'h8 && ps2_clk_negedge) transmitter_next_state = TX_STOP_BIT;
			else 													  transmitter_next_state = TX_PAYLOAD;
		end
		
		TX_STOP_BIT: begin
			if (ps2_clk_negedge) transmitter_next_state = TX_WAIT_ACK;
			else  					transmitter_next_state = TX_STOP_BIT;
		end
      
		TX_WAIT_ACK: begin
			if (rx_ack) transmitter_next_state = TX_IDLE;
			else transmitter_next_state = TX_WAIT_ACK;
		end
		
		TX_ERROR: begin
			if (~tx_req) transmitter_next_state = TX_IDLE;
			else 			 transmitter_next_state = TX_ERROR;
		end
		
      default: begin
         transmitter_next_state = TX_IDLE;
      end
   endcase
end


//------------------------------------------ Control signals ----------------------------------------//
always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) command_initiate_cnt <= {NUMBER_OF_BITS_FOR_101US{1'b0}};
    else if (transmitter_state != TX_INIT_DELAY) command_initiate_cnt <= {NUMBER_OF_BITS_FOR_101US{1'b0}};
	 else command_initiate_cnt <= command_initiate_cnt + COUNTER_INCREMENT_FOR_101US;
end

always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) tx_error_cnt <= {NUMBER_OF_BITS_FOR_15MS{1'b0}};
    else if (transmitter_state != TX_START_BIT) tx_error_cnt <= {NUMBER_OF_BITS_FOR_15MS{1'b0}};
	 else tx_error_cnt <= tx_error_cnt + COUNTER_INCREMENT_FOR_15MS;
end

always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) payload_cnt <= 4'h0;
    else if (transmitter_state != TX_PAYLOAD) payload_cnt <= 4'h0;
	 else if (ps2_clk_negedge) payload_cnt <= payload_cnt + 4'h1;
end

always_ff @(posedge clk, negedge rstn) begin
	if (~rstn) tx_payload_shift_reg <= 9'b0;
	else if (transmitter_state == TX_INIT_DELAY) tx_payload_shift_reg <= {{(^tx_payload) ^ 1'b1},tx_payload};
	else if (transmitter_state == TX_PAYLOAD && ps2_clk_negedge) tx_payload_shift_reg <= {1'b0, tx_payload_shift_reg[8:1]};
end

always_ff @(posedge clk, negedge rstn) begin
	if (~rstn) tx_ack_wait <= 1'b0;
	else if (transmitter_next_state == TX_WAIT_ACK) tx_ack_wait <= 1'b1;
	else tx_ack_wait <= 1'b0;
end

always_ff @(posedge clk, negedge rstn) begin
	if (~rstn) tx_error <= 1'b0;
	else if (transmitter_next_state == TX_ERROR) tx_error <= 1'b1;
	//else tx_error <= 1'b0;
end

always_ff @(posedge clk, negedge rstn) begin
	if (~rstn) tx_valid <= 1'b0;
	else if (transmitter_next_state == TX_WAIT_ACK) tx_valid <= 1'b1;
	else tx_valid <= 1'b0;
end

//assign tx_error = (transmitter_state == TX_ERROR);


//----------------------------------------- PS2 Output Control --------------------------------------//
assign ps2_clk_o_next   = (transmitter_next_state == TX_START_BIT) ? 1'b1 :
								  (transmitter_state == TX_INIT_DELAY) 	 ? 1'b0 : 1'b1;		// ????

assign ps2_clk_oe_next  = (transmitter_state == TX_INIT_DELAY) ? 1'b1 : 1'b0;

assign ps2_data_o_next  = (transmitter_state == TX_INIT_DELAY && 
								   command_initiate_cnt[NUMBER_OF_BITS_FOR_101US-1]) ? 1'b0 						 :
								  (transmitter_state == TX_START_BIT)  				  ? 1'b0 						 :
								  (transmitter_state == TX_PAYLOAD)  					  ? tx_payload_shift_reg[0] :
								  (transmitter_state == TX_STOP_BIT)  					  ? 1'b1 						 : 1'b1;	  

assign ps2_data_oe_next = ~(transmitter_state == TX_IDLE || transmitter_state == TX_WAIT_ACK);


always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) ps2_clk_o <= 1'b1;
    else ps2_clk_o <= ps2_clk_o_next;
end

always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) ps2_clk_oe <= 1'b0;
    else ps2_clk_oe <= ps2_clk_oe_next;
end  

always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) ps2_data_o <= 1'b1;
    else ps2_data_o <= ps2_data_o_next;
end  

always_ff @(posedge clk, negedge rstn) begin
    if (~rstn) ps2_data_oe <= 1'b0;
    else ps2_data_oe <= ps2_data_oe_next;
end 


endmodule
