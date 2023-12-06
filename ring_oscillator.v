module ring_oscillator #(
parameter WIDTH = 7 
)(
input  clk,
input  rst,
input  en_i,

output d_o
);

(* DONT_TOUCH = "yes" *) wire [WIDTH : 0] s;

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin 
        LUT1 #(
           .INIT(2'b01) 
        ) LUT1_inst (
           .O(s[i + 1]), 
           .I0(s[i]) 
        );
    end
endgenerate

and (s[0], s[WIDTH], en_i);

FDRE #(
   .INIT(1'b0) 
) FDRE_inst (
   .Q(d_o),      
   .C(clk),                       
   .CE(en_i),                        
   .R(rst),                     
   .D(s[0])                
);

endmodule