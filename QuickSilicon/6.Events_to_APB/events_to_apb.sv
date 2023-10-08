module events_to_apb 
(
    input   logic         clk,
    input   logic         reset,

    input   logic         event_a_i,
    input   logic         event_b_i,
    input   logic         event_c_i,

    output  logic         apb_psel_o,
    output  logic         apb_penable_o,
    output  logic [31:0]  apb_paddr_o,
    output  logic         apb_pwrite_o,
    output  logic [31:0]  apb_pwdata_o,
    input   logic         apb_pready_i
);

typedef enum logic [1:0] {EVENT_A, EVENT_B, EVENT_C, NO_EVENT} event_t;

typedef enum logic [1:0] {IDLE, SETUP, ACCESS} state_t;

event_t req_event;
//event_t last_event;
state_t state, next_state;

logic [31:0] event_a_cnt;
logic [31:0] event_b_cnt;
logic [31:0] event_c_cnt;


always_ff @(posedge clk or posedge reset) begin : EVENT_A_COUNTER
    if (reset) event_a_cnt <= 'b0;
    else if(event_a_i && state == SETUP) event_a_cnt <= 'b1;
    else if (event_a_i) event_a_cnt <= event_a_cnt + 'b1;
    else ;
end 

always_ff @(posedge clk or posedge reset) begin : EVENT_B_COUNTER
    if (reset) event_b_cnt <= 'b0;
    else if(event_b_i && state == SETUP) event_b_cnt <= 'b1;
    else if (event_b_i) event_b_cnt <= event_b_cnt + 'b1;
    else ;
end 

always_ff @(posedge clk or posedge reset) begin : EVENT_C_COUNTER
    if (reset) event_c_cnt <= 'b0;
    else if(event_c_i && state == SETUP) event_c_cnt <= 'b1;
    else if (event_c_i) event_c_cnt <= event_c_cnt + 'b1;
    else ;
end


always_ff @(posedge clk or posedge reset) begin : DETECT_REQ_EVENT
    if (reset) req_event <= NO_EVENT;
    else begin
        if(state == IDLE) begin
            if (event_a_i) req_event <= EVENT_A;
            else if (event_b_i) req_event <= EVENT_B;
            else if (event_c_i) req_event <= EVENT_C;
            else req_event <= NO_EVENT;
        end
        else req_event <= NO_EVENT;
    end
end

// always_ff @(posedge clk or posedge reset) begin : SAVE_LAST_EVENT
//     if (reset) last_event <= NO_EVENT;
//     else if (state == SETUP) last_event <= req_event;
//     else ;
// end

always_ff @(posedge clk or posedge reset) begin : TRANSITION_LOGIC
    if (reset) state <= IDLE;
    else state <= next_state;
end

always_comb begin
    case (state)
        IDLE: begin
            apb_psel_o = 'b0;
            apb_penable_o = 'b0;
            apb_paddr_o = 'b0;
            apb_pwdata_o = 'b0;
            if (event_a_i | event_b_i | event_c_i) next_state = SETUP;
            else next_state = IDLE;
        end

        SETUP: begin
            apb_psel_o = 'b1;
            apb_penable_o = 'b0;
            apb_paddr_o  = (req_event == EVENT_A) ? 32'hABBA0000 :
                           (req_event == EVENT_B) ? 32'hBAFF0000 :
                           (req_event == EVENT_C) ? 32'hCAFE0000 : 32'b0;
            apb_pwdata_o = (req_event == EVENT_A) ? event_a_cnt :
                           (req_event == EVENT_B) ? event_b_cnt :
                           (req_event == EVENT_C) ? event_c_cnt : 32'b0;
            next_state = ACCESS;
        end
        
        ACCESS: begin
            apb_psel_o = 'b1;
            apb_penable_o = 'b1;
            if (apb_pready_i) next_state = IDLE;    // not supported back-to-back
            else next_state = ACCESS;
        end 
        
        default: begin 
            apb_psel_o = 'b0;
            apb_penable_o = 'b0;
            apb_paddr_o = 'b0;
            apb_pwdata_o = 'b0;
            next_state = IDLE;
        end
    endcase
end

assign apb_pwrite_o = 1'b1;   // only write transaction

endmodule