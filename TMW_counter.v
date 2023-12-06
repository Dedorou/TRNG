module tmw_counter #(
parameter WIDTH = 5
)(
input                  clk, 
input                  rst, 
input                  en_i,
input  [WIDTH - 1 : 0] max_counts_i,

output                 ro_en_o,
output [WIDTH - 1 : 0] d_o
);

reg [WIDTH - 1 : 0] counter;
reg                 ro_en_reg;

always @(posedge clk) begin
  if (rst) begin 
    counter = 'b0;
  end else if (en_i) begin 
    if (counter == max_counts_i) begin    
      counter <= counter;
    end else begin 
      counter <= counter + 1;
    end
  end 
end

always @(posedge clk ) begin
  if (rst | (counter == max_counts_i)) begin 
    ro_en_reg <= 1'b0;
  end else if (en_i) begin 
    ro_en_reg <= 1'b1;
  end
end

assign d_o     = counter;
assign ro_en_o = ro_en_reg;

endmodule 