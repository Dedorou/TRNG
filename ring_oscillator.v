module ring_oscillator #(
parameter N = 7 
)(
input  clk,
input  rst,
input  en,
output out
);

(* DONT_TOUCH = "yes" *) wire [N : 0] s;

genvar i;
generate
    for (i = 0; i < N; i = i + 1) begin 
        LUT1 #(
           .INIT(2'b01) 
        ) LUT1_inst (
           .O(s[i + 1]), 
           .I0(s[i]) 
        );
    end
endgenerate

and (s[0], s[N], en);

FDRE #(
   .INIT(1'b0) 
) FDRE_inst (
   .Q(out),      
   .C(clk),                       
   .CE(en),                        
   .R(rst),                     
   .D(s[0])                
);

endmodule