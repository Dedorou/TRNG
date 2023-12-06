module register_map #(
parameter ADDR_WIDTH = 13,
parameter LFSR_WIDTH = 12,
parameter TMW_WIDTH  = 12,
parameter RO_WIDTH   = 7
)(
input  logic                      clk,
input  logic                      rst,
input  logic                      en_i,
input  logic              [3 : 0] we_i,
input  logic [ADDR_WIDTH - 1 : 0] addr_i,
input  logic             [31 : 0] wrdata_i,
    
output logic             [31 : 0] rdata_o
);

localparam LFSR_WE_WIDTH = (LFSR_WIDTH - 1)/8 + 1;
localparam TMW_WE_WIDTH  = (TMW_WIDTH - 1)/8 + 1;

logic                      request_reg_o;
logic [LFSR_WIDTH - 1 : 0] lfsr_o;
logic [LFSR_WIDTH - 1 : 0] lfsr_poly_reg_o; 
logic  [TMW_WIDTH - 1 : 0] tmw_o;
logic  [TMW_WIDTH - 1 : 0] tmw_max_reg_o;
logic                      ro_reg_o;

logic                         request_reg_we;
logic [LFSR_WE_WIDTH - 1 : 0] lfsr_we;
logic [LFSR_WE_WIDTH - 1 : 0] lfsr_poly_reg_we;
logic  [TMW_WE_WIDTH - 1 : 0] tmw_max_reg_we;

logic [31 : 0] rdata_int;

always_comb begin
  rdata_int        = 'h0;
  request_reg_we   = 'h0;
  lfsr_we          = 'h0;
  lfsr_poly_reg_we = 'h0;
  tmw_max_reg_we   = 'h0;
  case (addr_i[ADDR_WIDTH - 1 : 4])
    'h1 : begin : request_reg_addr
      request_reg_we = en_i & we_i[0];
      rdata_int[0]   = request_reg_o; 
    end
    'h2 : begin : lfsr_reg_addr
      lfsr_we                       = {LFSR_WE_WIDTH{en_i}} & we_i;
      rdata_int[LFSR_WIDTH - 1 : 0] = lfsr_o; 
    end
    'h3 : begin : lfsr_poly_reg_addr
      lfsr_poly_reg_we              = {LFSR_WE_WIDTH{en_i}} & we_i;
      rdata_int[LFSR_WIDTH - 1 : 0] = lfsr_poly_reg_o; 
    end
    'h4 : begin : tmw_addr 
      rdata_int[TMW_WIDTH - 1 : 0]  = tmw_o; 
    end
    'h5 : begin : tmw_max_reg_addr
      tmw_max_reg_we                = {TMW_WE_WIDTH{en_i}} & we_i;
      rdata_int[TMW_WIDTH - 1 : 0]  = tmw_max_reg_o; 
    end
    'h6 : begin : ro_reg_addr
      rdata_int[0]                  = ro_reg_o;
    end
  endcase
end

always_ff @( clk ) begin
  rdata_o <= rdata_int;
end

byte_write_register #(
  .WIDTH      (1)
) request_reg (
  .clk (clk),
  .rst (rst),
  .we_i(request_reg_we),
  .d_i (wrdata_i[0]),
  .d_o (request_reg_o)
);

byte_write_register #(
  .WIDTH      (LFSR_WIDTH),
  .BYTE_WIDTH (8)
) lfsr_reg (
  .clk (clk),
  .rst (rst),
  .we_i(),
  .d_i (wrdata_i[LFSR_WIDTH - 1 : 0]),
  .d_o (lfsr_o[LFSR_WIDTH - 1 : 0])
);

byte_write_register #(
  .WIDTH      (LFSR_WIDTH),
  .BYTE_WIDTH (8)
) lfsr_poly_reg (
  .clk (clk),
  .rst (rst),
  .we_i(lfsr_poly_reg_we),
  .d_i (wrdata_i[LFSR_WIDTH - 1 : 0]),
  .d_o (lfsr_poly_reg_o[LFSR_WIDTH - 1 : 0])
);

tmw_counter #(
  .WIDTH (TMW_WIDTH)
) tmw_counter (
  .clk         (clk),
  .rst         (rst),
  .en_i        (request_reg_o),
  .max_counts_i(tmw_max_reg_o),
  .ro_en_o     (),
  .d_o         (tmw_o[TMW_WIDTH - 1 : 0])
);

byte_write_register #(
  .WIDTH      (TMW_WIDTH),
  .BYTE_WIDTH (8)
) tmw_max_reg (
  .clk (clk),
  .rst (rst),
  .we_i(tmw_max_reg_we),
  .d_i (wrdata_i[TMW_WIDTH - 1 : 0]),
  .d_o (tmw_max_reg_o[TMW_WIDTH - 1 : 0])
);

endmodule
