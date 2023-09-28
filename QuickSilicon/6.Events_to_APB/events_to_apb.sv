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

logic [31:0] event_a_cnt;
logic [31:0] event_b_cnt;
logic [31:0] event_c_cnt;

logic write_transaction;
event_t req_event;

always_ff @(posedge clk or posedge reset) begin : EVENT_A_COUNTER
    if (reset) event_a_cnt <= 'b0;
    else if (event_a_i) event_a_cnt <= event_a_cnt + 'b1;
    else ;
end 

always_ff @(posedge clk or posedge reset) begin : EVENT_B_COUNTER
    if (reset) event_b_cnt <= 'b0;
    else if (event_b_i) event_b_cnt <= event_b_cnt + 'b1;
    else ;
end 

always_ff @(posedge clk or posedge reset) begin : EVENT_C_COUNTER
    if (reset) event_c_cnt <= 'b0;
    else if (event_c_i) event_c_cnt <= event_c_cnt + 'b1;
    else ;
end

always_ff @(posedge clk or posedge reset) begin : DETECT_REQ
    if (reset) write_transaction <= 'b0;
    else if (apb_pready_i) write_transaction <= 'b0;
    else if (event_a_i | event_b_i | event_c_i) write_transaction <= 'b1;
    else ;
end

always_ff @(posedge clk or posedge reset) begin : DETECT_EVENT
    if (reset) req_event <= NO_EVENT;
    else begin
        if(write_transaction) begin
            if(event_a_i) req_event <= EVENT_A;
            else if(event_b_i) req_event <= EVENT_B;
            else if(event_c_i) req_event <= EVENT_C;
            else ;
        end
        else req_event <= NO_EVENT;
    end
end

assign apb_pwrite_o = 1'b1;   // only write transaction

assign apb_psel_o = (write_transaction) ? 'b1 : 'b0;

assign apb_penable_o = (req_event != NO_EVENT) ? 'b1 : 'b0;

assign apb_paddr_o = (req_event == EVENT_A) ? 32'hABBA0000 :
                     (req_event == EVENT_B) ? 32'hBAFF0000 :
                     (req_event == EVENT_C) ? 32'hCAFE0000 : 32'b0;

assign apb_pwdata_o = (req_event == EVENT_A) ? event_a_cnt :
                      (req_event == EVENT_B) ? event_b_cnt :
                      (req_event == EVENT_C) ? event_c_cnt : 32'b0;

endmodule