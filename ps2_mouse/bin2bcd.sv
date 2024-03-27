module bin2bcd 
(
	input  logic 		 clk,
	input  logic 		 rstn,
	input  logic [7:0] lfsr_in,
	output logic [3:0] bcd_ed,
	output logic [3:0] bcd_des,
	output logic [3:0] bcd_hun
);

logic [7:0]  lfsr_ff;
logic [3:0]  cnt;
logic [3:0]  bcd_ed_ff;
logic [3:0]  bcd_des_ff;
logic [3:0]  bcd_hun_ff;
logic 		 val;
logic 		 not_used;
logic [11:0] no_corr;
logic [11:0] corr_ed;
logic [11:0] corr_des;
logic [11:0] corr_des_ed;

always @(posedge clk or negedge rstn) begin
	if (~rstn) cnt <= 4'b0;
	else if (cnt == 4'd9) cnt <= 4'b0;
	else cnt <= cnt + 4'd1;
end

always @(posedge clk or negedge rstn) begin
	if (~rstn) {val,lfsr_ff} <= 9'b0;
	else if (cnt == 4'd9) {val,lfsr_ff} <= {1'b0,lfsr_in};
	else {val, lfsr_ff} <= {lfsr_ff[7:0],1'b0};
end

assign no_corr = {bcd_hun_ff, bcd_des_ff, bcd_ed_ff,val};
assign corr_ed = {bcd_hun_ff, bcd_des_ff, bcd_ed_ff} + 12'd3;		 // +3
assign corr_des = {bcd_hun_ff, bcd_des_ff, bcd_ed_ff} + 12'd48;	 // +30 (in bcd)
assign corr_des_ed = {bcd_hun_ff, bcd_des_ff, bcd_ed_ff} + 12'd51; // +33 (in bcd)

always @(posedge clk or negedge rstn) begin
	if (~rstn) {bcd_hun_ff, bcd_des_ff, bcd_ed_ff} <= 12'b0;
	else if (cnt == 4'd9) {bcd_hun_ff, bcd_des_ff, bcd_ed_ff} <= 12'b0;  
    else if (bcd_ed_ff >= 4'd5) begin
		if (bcd_des_ff >= 4'd5) {not_used, bcd_hun_ff, bcd_des_ff, bcd_ed_ff} <= {corr_des_ed, val};
		else {not_used, bcd_hun_ff, bcd_des_ff, bcd_ed_ff} <= {corr_ed, val};
	end
	else if (bcd_des_ff >= 4'd5) {not_used, bcd_hun_ff, bcd_des_ff, bcd_ed_ff} <= {corr_des, val};
	else {not_used, bcd_hun_ff, bcd_des_ff, bcd_ed_ff} <= no_corr;

end

always @(posedge clk or negedge rstn) begin
	if (~rstn) begin
		 bcd_ed  <= 4'b0;
		 bcd_des <= 4'b0;
	    bcd_hun <= 4'b0;
	end
	else if (cnt == 4'd9) begin
	    bcd_ed  <= bcd_ed_ff;
	    bcd_des <= bcd_des_ff;
	    bcd_hun <= bcd_hun_ff;
	end
end

endmodule