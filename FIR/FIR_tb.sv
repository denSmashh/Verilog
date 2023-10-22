`timescale 1us / 1us

module FIR_tb ();

localparam FIR_WIDTH = 16;
localparam COEFF_WIDTH = 16;
localparam NUM_TAPS = 25;

reg clock; 
reg reset;
wire signed [2*FIR_WIDTH+4:0] out; 

real freq;                          // текущее значение частоты синусоиды
real t;                             // аргумент функции sin(x)
real sin_real;                      // значение функции sin(x)
reg signed [FIR_WIDTH-1:0] sin_reg; // целочисленное значение
// sin(x) в 16-битном двоичном представлении
// с фиксированной точкой


FIR  
#(
    .WIDTH(FIR_WIDTH),               
    .COEFF_WIDTH(COEFF_WIDTH),         
    .TAPS(NUM_TAPS)                 
) i_FIR 
(
    .clk(clock),
    .rst(reset),
    .in(sin_reg),
    .out(out)
);


always begin
    #250 clock = ~clock;    // 2000 Hz
end

initial begin
    clock = 1; 
    reset = 0; 
    #50 reset = 1; 
    #100 reset = 0;

    freq = 0;
    t = 0;

    // генерация синусоиды
    forever begin
        freq = freq + 0.1;
        sin_real = $sin(t);
        t = t + (2*3.14)*freq*0.0005;
        sin_reg = $rtoi(sin_real*2**(15));
        #500;
    end

end


endmodule