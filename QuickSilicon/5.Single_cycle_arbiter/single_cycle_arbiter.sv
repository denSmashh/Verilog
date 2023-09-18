// priority encoder implementation

module single_cycle_arbiter #(
  parameter N = 32
) (
  input   logic          clk,
  input   logic          reset,
  input   logic [N-1:0]  req_i,
  output  logic [N-1:0]  gnt_o
);

// ------- Slow realization (Priority encoder) ------- //
// always_comb begin : PRIORITY_ARBITER
//     gnt_o = 'b0;
//     for (int i = N-1; i >= 0; i = i - 1) begin
//       if(req_i[i]== 1'b1) begin
//           gnt_o = 1 << i;
//       end
//   end 
// end

// ---------- Perfomance realization ---------- //
// Input[0] has a highest prioroty => will serviced first.
// Then if i-1 not request will serviced i.
logic [N-1:0] priority_req;

assign priority_req[0] = 1'b0;

genvar i;
if(N > 0) begin
    for (i = 0; i < N ; i = i + 1) begin
        assign priority_req[i+1] = priority_req[i] | req_i[i];
    end
end

assign gnt_o = req_i[N-1:0] & ~priority_req[N-1:0];


endmodule
