module divide_by_3 (
    input   logic     clk,
    input   logic     reset,
    input   logic     x_i,
    output  logic     div_o
);
    
typedef enum logic [1:0] { REMAINDER_0, 
                           REMAINDER_1, 
                           REMAINDER_2 } state_t;


state_t state;
state_t next_state;

always_ff @(posedge clk, posedge reset) begin: TRANSITION_LOGIC
    if (reset) state <= REMAINDER_0;
    else state <= next_state;
end

always_comb begin   
    case (state)
        
        REMAINDER_0: begin
            if(x_i) begin
                next_state = REMAINDER_1;
                div_o = 1'b0;
            end
            else begin
                next_state = REMAINDER_0;
                div_o = 1'b1;
            end
        end            
        
        REMAINDER_1: begin
            if(x_i) begin
                next_state = REMAINDER_0;
                div_o = 1'b1;
            end
            else begin
                next_state = REMAINDER_2;
                div_o = 1'b0;
            end
        end
        
        REMAINDER_2: begin
            if(x_i) begin
                next_state = REMAINDER_2;
                div_o = 1'b0;
            end
            else begin
                next_state = REMAINDER_1;
                div_o = 1'b0;
            end
        end

        default: begin
            next_state = REMAINDER_0;
            div_o = 1'b1;
        end 
    endcase
end

endmodule
