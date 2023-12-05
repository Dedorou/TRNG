module param_reg #(
parameter N = 4
)(
input      clk, 
input      rst, 
input      we,
input      [N - 1 : 0] D,

output reg [N - 1 : 0] Q);

always @(posedge clk) begin 
	if (rst) begin 
		Q <= 0;
	end else if (we) begin 
		Q <= D;
	end 
end

endmodule

module byte_write_reg #(
parameter width = 32,
parameter byte_width = 8
)(
input                      clk, 
input                      rst, 
input      [3         : 0] we,
input      [width - 1 : 0] D,

output reg [width - 1 : 0] Q);

integer i;
always @(posedge clk) begin 
	if (rst) begin 
		Q <= 0;
	end else begin 
		for (i = 0; i < 4; i = i + 1) begin
			if (we[i]) begin
				Q[(byte_width * i) +: byte_width] <= D[(byte_width * i) +: byte_width];
			end
		end
	end 
end

endmodule