// FIR (Finite Impulse Response) filter
// Implement simple canonical schematic
// coeff.txt implement high-pass filter
// Сutoff frequency - 300 Hz

module FIR #(
    parameter WIDTH = 16,               // input data (signal) width
    parameter COEFF_WIDTH = 16,         // coefficent width
    parameter TAPS = 25                 // number of filter taps
)(
    input                       clk,
    input                       rst,
    input  signed [WIDTH-1:0]   in,
    output signed [2*WIDTH+4:0] out
);

//reg signed [COEFF_WIDTH-1:0] coeff [0:TAPS-1];
wire signed [COEFF_WIDTH-1:0] coeff [0:TAPS-1];
reg signed [WIDTH-1:0] shift_out [0:TAPS-1];
reg signed [2*WIDTH:0] mult_out  [0:TAPS-1];
reg signed [2*WIDTH+4:0] add_out [0:TAPS-1];


assign coeff[0] = -'h15;
assign coeff[1] = 'h6D9;
assign coeff[2] = -'h678;
assign coeff[3] = -'h456;
assign coeff[4] = -'h182;
assign coeff[5] = 'h27D;
assign coeff[6] = 'h60C;
assign coeff[7] = 'h684;
assign coeff[8] = 'h1D1;
assign coeff[9] = -'h7F5;
assign coeff[10] = -'h140D;
assign coeff[11] = -'h1e11;
assign coeff[12] = 'h5e11;
assign coeff[13] = -'h1e11;
assign coeff[14] = -'h140D;
assign coeff[15] = -'h7F5;
assign coeff[16] = 'h1D1;
assign coeff[17] = 'h684;
assign coeff[18] = 'h60C;
assign coeff[19] = 'h27D;
assign coeff[20] = -'h182;
assign coeff[21] = -'h456;
assign coeff[22] = -'h678;
assign coeff[23] = 'h6D9;
assign coeff[24] = 'h15;

//initial begin
//   $readmemh("coeff.txt", coeff);   // load coefficients
//end


genvar i;
generate
    
    // shift
    for (i = 0; i < TAPS; i = i + 1) begin
        always @(posedge clk) begin
            if (rst) begin
                shift_out[i] <= 'b0;
            end
            else begin
                if(i == 0)
                    shift_out[0] <= in;
                else 
                    shift_out[i] <= shift_out[i-1];
            end
        end
    end    

    // multiplication
    for (i = 0; i < TAPS; i = i + 1) begin
        always @ (*) begin
            mult_out[i] = coeff[TAPS-1-i] * shift_out[i];
        end
    end

    // addition
    for (i = 0; i < TAPS-1; i = i + 1) begin
        always @ (*) begin
            add_out[0] = mult_out[0];
            add_out[i+1] = add_out[i] + mult_out[i+1];
        end
    end    

endgenerate

assign out = add_out[TAPS-1];

endmodule
