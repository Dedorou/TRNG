module TMW_counter #(
parameter N = 5
)(
input              clk, 
input              rst, 
input              valid,
input  [N - 1 : 0] max_counts,

output             en_out,
output [N - 1 : 0] data
);

reg    [N - 1 : 0] counter;
reg    [N - 1 : 0] max_counts_reg;
reg                valid_reg;

always @(posedge clk) begin
    if (rst | valid) begin 
        counter = 'b0;
    end else if (valid_reg) begin 
        counter = counter + 1'b1;
    end 
end

//trigger or latch?????????
always @(posedge clk) begin 
    if (rst | (counter == max_counts_reg))
        valid_reg = 'b0;
    else if (valid) begin
        valid_reg = 'b1;
    end
end

always @(posedge clk) begin 
    if (rst)
        max_counts_reg = 'b0;
    else if (valid) begin
        max_counts_reg = max_counts;
    end
end

assign en_out = valid_reg;
assign data   = counter;

endmodule 