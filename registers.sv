module register #(
parameter WIDTH = 4
)(
input  logic                 clk, 
input  logic                 rst, 
input  logic                 we_i,
input  logic [WIDTH - 1 : 0] d_i,
 
output logic [WIDTH - 1 : 0] d_o);

always_ff @(posedge clk) begin
  if (rst)
    d_o <= 'b0;
  else 
    if (we_i)
      d_o <= d_i;
end

endmodule

module byte_write_register #(
parameter WIDTH      = 32,
parameter BYTE_WIDTH = 8,
parameter WE_WIDTH   = (WIDTH - 1)/BYTE_WIDTH + 1
)(
input  logic                    clk, 
input  logic                    rst, 
input  logic [WE_WIDTH - 1 : 0] we_i,
input  logic    [WIDTH - 1 : 0] d_i,
   
output logic    [WIDTH - 1 : 0] d_o);

always_ff @(posedge clk) begin
  if (rst)
    d_o <= 'b0;
  else
    for (integer i = 0; i < WE_WIDTH; i = i + 1) begin 
      if (we_i[i])
	    d_o[(BYTE_WIDTH * i) +: BYTE_WIDTH] <= d_i[(BYTE_WIDTH * i) +: BYTE_WIDTH];	
	end
end 

endmodule