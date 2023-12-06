module register_map #(
parameter addr_width = 13,
parameter lfsr_width = 12,
parameter tmw_width = 12,
parameter ro_width = 7
)(
input  logic                      clk,
input  logic                      rst,
input  logic                      en,
input  logic              [3 : 0] we,
input  logic [addr_width - 1 : 0] addr,
input  logic             [31 : 0] wrdata,
    
output logic             [31 : 0] rdata
);

logic                      request_o;
logic [lfsr_width - 1 : 0] lfsr_o;
logic [lfsr_width - 1 : 0] lfsr_poly_o; 
logic  [tmw_width - 1 : 0] tmw_o;
logic  [tmw_width - 1 : 0] tmw_max_o;
logic                      ro_o;

logic         request_we;
logic [3 : 0] lfsr_we;
logic [3 : 0] lfsr_poly_we;
logic [3 : 0] tmw_we;
logic [3 : 0] tmw_max_we;

logic [31 : 0] rdata_int;

always_comb begin
  rdata        = 'h0;
  request_we   = 'h0;
  lfsr_we      = 'h0;
  lfsr_poly_we = 'h0;
  tmw_we       = 'h0;
  tmw_max_we   = 'h0;
  case (addr[addr_width - 1 : 4])
    'h1 : begin : request_addr
      request_we   = en & we[0];
      rdata_int[0] = request_o; 
    end
    'h2 : begin : lfsr_addr
      lfsr_we                       = {4{en}} & we;
      rdata_int[lfsr_width - 1 : 0] = lfsr_o; 
    end
    'h3 : begin : lfsr_poly_addr
      lfsr_poly_we                  = {4{en}} & we;
      rdata_int[lfsr_width - 1 : 0] = lfsr_poly_o; 
    end
    'h4 : begin : tmw_addr 
      tmw_we                        = {4{en}} & we;
      rdata_int[tmw_width - 1 : 0]  = lfsr_poly_o; 
    end
    'h5 : begin : tmw_max_addr
      tmw_max_we                    = {4{en}} & we;
      rdata_int[tmw_width - 1 : 0]  = lfsr_poly_o; 
    end
    'h6 : begin : ro_addr
      rdata_int[0] = ro_o;
    end
  endcase
end

always_ff @( clk ) begin
  rdata <= rdata_int;
end

endmodule
