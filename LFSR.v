module lfsr #(
parameter WIDTH = 5
)(    
input                 clk, 
input                 rst, 
input                 en_i,
input  [WIDTH -1 : 0] polynom_i,
input                 seed_we_i,
input  [WIDTH -1 : 0] seed_i,
input                 ro_i,

output [WIDTH -1 : 0] d_o
);

reg [WIDTH -1 : 0] lfsr_reg;
reg                feedback;
      
wire               lfsr_in;

integer i;
always @(*) begin
  feedback = lfsr_reg[0];
  for (i = 1; i < WIDTH; i = i + 1) begin
    if (polynom_i[WIDTH - 1 - i] == 1'b1) begin
      feedback = feedback ^ lfsr_reg[i];
    end
  end
end

//assign lfsr_in = feedback ^ ro_i;

always @(posedge clk ) begin
  if (rst) begin
    lfsr_reg <= 'b0;
  end else if (seed_we_i) begin
    lfsr_reg <= seed_i;
  end else if (en_i) begin 
    lfsr_reg <= {feedback, lfsr_reg[WIDTH - 1 : 1]};
  end
end

assign d_o = lfsr_reg;

endmodule      

   
   
   
   
   
   
   
   
   
