module LFSR #(
parameter                width = 10,
parameter [width -1 : 0] polynom = 'h204
)(    
input                    clk, 
input                    rst, 
input                    en,
input                    seed_we,
input     [width -1 : 0] seed,
input                    ring_oscillator,

output    [width -1 : 0] data_out
);

reg       [width -1 : 0] LFSR_reg;
reg                      feedback;
      
wire                     LFSR_in;

integer i;
always @(*) begin
    feedback = LFSR_reg[0];
    for (i = 0; i < width; i = i + 1) begin
        if (polynom[i] == 1'b1) begin
            feedback = feedback ^ LFSR_reg[i];
        end
    end
end

assign LFSR_in = feedback ^ ring_oscillator;

always @(posedge clk ) begin
    if (rst) begin
        LFSR_reg <= 'b0;
    end else if (seed_we) begin
        LFSR_reg <= seed;
    end else if (en) begin 
        LFSR_reg <= {LFSR_in, LFSR_reg[width - 1 : 1]};
    end
end

assign data_out = LFSR_reg;

endmodule      

   
   
   
   
   
   
   
   
   
